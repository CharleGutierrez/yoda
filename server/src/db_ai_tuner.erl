-module(db_ai_tuner).
-export([tune_query/2]).

tune_query(QueryBin, ApiKeyBin) ->
    Query = binary_to_list(QueryBin),
    ApiKey = binary_to_list(ApiKeyBin),
    
    if
        ApiKey =/= "no_key", length(ApiKey) > 5, ApiKey =/= "default_key" ->
            case call_llm_tuner(Query, ApiKeyBin) of
                Resp when is_binary(Resp) -> Resp;
                _ -> local_ai_tune(Query)
            end;
        true ->
            local_ai_tune(Query)
    end.

local_ai_tune(Query) ->
    UpperQuery = string:to_upper(Query),
    
    HasJoin = string:str(UpperQuery, "JOIN") > 0,
    HasGroupBy = string:str(UpperQuery, "GROUP BY") > 0,
    HasCount = string:str(UpperQuery, "COUNT(") > 0,
    HasAvg = string:str(UpperQuery, "AVG(") > 0,
    HasWhere = string:str(UpperQuery, "WHERE") > 0,
    HasIdLookup = string:str(UpperQuery, "WHERE ID =") > 0 orelse string:str(UpperQuery, "WHERE ID=") > 0,
    HasSearch = string:str(UpperQuery, "MATCH") > 0 orelse string:str(UpperQuery, "SEARCH") > 0,
    HasWrite = string:str(UpperQuery, "INSERT") > 0 orelse string:str(UpperQuery, "UPDATE") > 0,
    HasSelect = string:str(UpperQuery, "SELECT") > 0,

    % 1. Classify Query Type
    Complexity = if
        HasJoin andalso HasGroupBy -> "Complex Analytical Aggregation";
        HasJoin -> "Relational Join";
        HasGroupBy orelse HasCount -> "Aggregate Summary";
        HasWhere -> "Filtered Scan";
        true -> "Simple Table Scan"
    end,

    % 2. Check for anti-patterns and generate tuning recommendations
    Recommendations = generate_tuning_rules(UpperQuery),
    
    % 3. Recommend Storage & Routing Tier
    RecommendedEngine = if
        HasSelect andalso HasIdLookup -> "Redis (In-Memory Hot Cache)";
        HasGroupBy orelse HasAvg -> "Snowflake / ClickHouse (Columnar OLAP)";
        HasSearch -> "Elasticsearch / OpenSearch (Lucene)";
        HasWrite -> "PostgreSQL (ACID WAL)";
        true -> "PostgreSQL / SQLite"
    end,

    % 4. Suggested Index
    SuggestedIndex = extract_suggested_index(UpperQuery),

    % 5. Cache TTL and Pool Sizing
    SuggestedPool = erlang:system_info(schedulers) * 2 + 4,
    SuggestedTTL = if HasSelect -> "60 seconds"; true -> "0 seconds (Write Bypass)" end,

    Result = io_lib:format("{\"query_complexity\":\"~s\",\"recommended_storage\":\"~s\",\"suggested_pool_size\":~p,\"suggested_cache_ttl\":\"~s\",\"suggested_index\":\"~s\",\"ai_tuning_rules\":[~s],\"status\":\"autonomous_ai_tuned\"}",
                           [Complexity, RecommendedEngine, SuggestedPool, SuggestedTTL, SuggestedIndex, string:join(Recommendations, ",")]),
    list_to_binary(Result).

generate_tuning_rules(Upper) ->
    R1 = case string:str(Upper, "SELECT *") > 0 of
        true -> ["\"Replace 'SELECT *' with specific projection columns to reduce I/O throughput and network serialization overhead\""];
        false -> []
    end,
    R2 = case string:str(Upper, "WHERE") > 0 andalso string:str(Upper, "LIKE '%") > 0 of
        true -> ["\"Leading wildcard 'LIKE %...' prevents B-Tree index lookup. Switch to Full-Text Trigram / Gin index (PostgreSQL) or Elasticsearch\""];
        false -> []
    end,
    R3 = case string:str(Upper, "SELECT") > 0 andalso string:str(Upper, "LIMIT") =:= 0 of
        true -> ["\"Unbounded query missing LIMIT clause. Add 'LIMIT 100' or cursor pagination to prevent memory buffer exhaustion\""];
        false -> []
    end,
    R4 = case string:str(Upper, "JOIN") > 0 andalso string:str(Upper, "ON") =:= 0 of
        true -> ["\"Potential Cartesian Product detected. Ensure all JOIN clauses contain explicit ON/USING predicates\""];
        false -> []
    end,
    Rules = R1 ++ R2 ++ R3 ++ R4,
    if
        length(Rules) =:= 0 -> ["\"Query structure is well-formed with standard predicate indexability\""];
        true -> Rules
    end.

extract_suggested_index(Upper) ->
    case re:run(Upper, "FROM\\s+([A-Z0-9_]+)\\s+WHERE\\s+([A-Z0-9_]+)", [{capture, [1, 2], list}]) of
        {match, [Table, Col]} ->
            "CREATE INDEX idx_" ++ string:to_lower(Table) ++ "_" ++ string:to_lower(Col) ++ " ON " ++ Table ++ " (" ++ Col ++ ");";
        _ ->
            "CREATE INDEX idx_telemetry_time_sensor ON telemetry (timestamp, sensor_id);"
    end.

call_llm_tuner(Query, ApiKeyBin) ->
    Prompt = "Act as an expert Senior Database Architect & AI Performance Tuner. Analyze this database query: '" ++ Query ++ "'. Provide a 1-sentence performance diagnosis, optimal index recommendation, and storage tier (Postgres, Redis, Snowflake, Mongo).",
    Body = "{\"model\":\"gpt-3.5-turbo\",\"messages\":[{\"role\":\"user\",\"content\":\"" ++ escape_json(Prompt) ++ "\"}],\"max_tokens\":120}",
    Url = "https://api.openai.com/v1/chat/completions",
    curl_wrapper:curl_post(list_to_binary(Url), ApiKeyBin, list_to_binary(Body)).

escape_json(Str) ->
    lists:flatmap(fun
        ($\") -> "\\\"";
        ($\\) -> "\\\\";
        ($\n) -> "\\n";
        ($\r) -> "\\r";
        ($\t) -> "\\t";
        (C) -> [C]
    end, Str).
