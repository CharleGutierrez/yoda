export async function do_fetch(url, body) {
  try {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: body
    });
    const data = await response.json();
    if (data.choices && data.choices.length > 0) {
      return data.choices[0].message.content;
    }
    return JSON.stringify(data);
  } catch (err) {
    console.error("AI Fetch Error:", err);
    return "Error connecting to AI Gateway";
  }
}

export function do_fetch_cb(url, body, cb) {
  do_fetch(url, body).then(cb);
}

export async function fetch_history(cb) {
  try {
    const response = await fetch('/api/history');
    const data = await response.json();
    cb(data.join('\\n'));
  } catch (err) {
    console.error("History fetch error:", err);
  }
}

export function connect_ws(token, onOpen, onMessage, onClose) {
  const ws = new WebSocket(`ws://localhost:8000/ws?token=${token}`);
  ws.onopen = () => {
    ws.send("start");
    if (onOpen) onOpen();
  };
  ws.onmessage = (event) => {
    if (onMessage) onMessage(event.data);
  };
  ws.onclose = () => {
    if (onClose) onClose();
  };
}

export function start_resource_polling(cb) {
  setInterval(async () => {
    try {
      const response = await fetch('/api/system_resources');
      const data = await response.text();
      cb(data);
    } catch (err) {
      console.error("Resource fetch error:", err);
    }
  }, 2000);
}
