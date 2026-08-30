class ComplexDataGrid extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
  }

  static get observedAttributes() {
    return ['data'];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    this.render();
  }

  connectedCallback() {
    this.render();
  }

  render() {
    let raw = this.getAttribute('data') || '';
    let rows = [];

    // 1. Try parsing directly as JSON
    try {
      const parsed = JSON.parse(raw);
      rows = Array.isArray(parsed) ? parsed : [parsed];
    } catch(e) {
      // 2. Parse multi-line telemetry format (Update: {..} / DBF_DATA: {..})
      const lines = raw.split('\n').filter(l => l.trim().length > 0);
      for (const line of lines.slice(-20)) {
        let cleaned = line.replace(/^Update:\s*/i, '').replace(/^DBF_DATA:\s*/i, '').replace(/^HFT Stream Active:\s*/i, '').trim();
        try {
          const item = JSON.parse(cleaned);
          if (item && typeof item === 'object') {
            if (item.fields) {
              rows.push({ index: item.record_index, ...item.fields });
            } else {
              rows.push(item);
            }
          } else {
            rows.push({ event: cleaned });
          }
        } catch(err) {
          if (cleaned) {
            rows.push({ raw_telemetry: cleaned });
          }
        }
      }
    }

    if (rows.length === 0) {
      rows = [{ status: 'Waiting for stream...', time: new Date().toLocaleTimeString() }];
    }

    // Extract dynamic unique keys
    const allKeys = Array.from(new Set(rows.flatMap(r => Object.keys(r)))).slice(0, 5);
    if (allKeys.length === 0) allKeys.push('telemetry');

    const headerHtml = allKeys.map(k => `<div class="cell header">${k.toUpperCase()}</div>`).join('');

    const rowHtml = rows.map(r => {
      let isAnomaly = false;
      for (const k of allKeys) {
        let v = parseFloat(r[k]);
        if (!isNaN(v) && v > 80) isAnomaly = true;
      }
      let bg = isAnomaly ? 'background: rgba(239, 68, 68, 0.35); border-color: rgba(239, 68, 68, 0.6);' : '';
      
      return allKeys.map(k => {
        let val = r[k] !== undefined ? (typeof r[k] === 'object' ? JSON.stringify(r[k]) : String(r[k])) : '—';
        return `<div class="cell" style="${bg}">${val}</div>`;
      }).join('');
    }).join('');

    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: block;
          width: 100%;
          overflow-x: auto;
        }
        .grid {
          display: grid;
          grid-template-columns: repeat(${allKeys.length}, minmax(120px, 1fr));
          gap: 6px;
          border: 1px solid rgba(255, 255, 255, 0.15);
          border-radius: 8px;
          padding: 12px;
          background: rgba(15, 23, 42, 0.65);
          backdrop-filter: blur(12px);
          color: #f8fafc;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', monospace;
          font-size: 13px;
        }
        .cell {
          padding: 8px 10px;
          border: 1px solid rgba(255, 255, 255, 0.08);
          border-radius: 4px;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
          background: rgba(30, 41, 59, 0.5);
        }
        .cell.header {
          font-weight: 700;
          color: #00ffa3;
          background: rgba(15, 23, 42, 0.9);
          border-bottom: 2px solid #00ffa3;
        }
      </style>
      <div class="grid">
        ${headerHtml}
        ${rowHtml}
      </div>
    `;
  }
}

class CustomCalendar extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
  }

  static get observedAttributes() {
    return ['event-text'];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    this.render();
  }

  connectedCallback() {
    this.render();
  }

  render() {
    let raw = this.getAttribute('event-text') || 'No Event';
    let text = raw;
    try {
      const parsed = JSON.parse(raw);
      if (parsed.diagnostic) {
        text = parsed.diagnostic;
      } else if (parsed.choices && parsed.choices[0] && parsed.choices[0].message) {
        text = parsed.choices[0].message.content;
      } else if (typeof parsed === 'string') {
        text = parsed;
      }
    } catch(e) {
      text = raw;
    }

    this.shadowRoot.innerHTML = `
      <style>
        .calendar-card {
          border: 1px solid rgba(0, 255, 163, 0.3);
          border-radius: 8px;
          padding: 14px;
          background: rgba(15, 23, 42, 0.7);
          color: #e2e8f0;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
          font-size: 13.5px;
          line-height: 1.5;
          margin-top: 10px;
          border-left: 4px solid #00ffa3;
        }
        .calendar-title {
          font-weight: 700;
          color: #00ffa3;
          margin-bottom: 6px;
          display: flex;
          align-items: center;
          gap: 6px;
        }
      </style>
      <div class="calendar-card">
        <div class="calendar-title">⚡ Autonomous AI Reliability Diagnostics</div>
        <p style="margin:0;">${text}</p>
      </div>
    `;
  }
}

customElements.define('complex-data-grid', ComplexDataGrid);
customElements.define('custom-calendar', CustomCalendar);

class LiveDataChart extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.dataPoints = [];
  }

  static get observedAttributes() { return ['data']; }

  attributeChangedCallback(name, oldVal, newVal) {
    if (newVal) {
      const lines = newVal.split('\n').filter(l => l.trim().length > 0);
      for (const line of lines) {
        let num = null;
        try {
          const parsed = JSON.parse(line.replace(/^Update:\s*/i, '').replace(/^DBF_DATA:\s*/i, '').trim());
          if (parsed && typeof parsed.value === 'number') {
            num = parsed.value;
          }
        } catch(e) {}
        
        if (num === null) {
          const match = line.match(/([0-9]+\.?[0-9]*)/);
          if (match) {
            num = parseFloat(match[1]);
          }
        }

        if (num !== null && !isNaN(num)) {
          this.dataPoints.push(num);
          if (this.dataPoints.length > 50) this.dataPoints.shift();
          if (num > 80) this.showAnomalyToast(num);
        }
      }
      this.renderChart();
    }
  }

  showAnomalyToast(val) {
    let toast = document.getElementById('anomaly-toast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'anomaly-toast';
      toast.style.cssText = 'position:fixed;top:20px;right:20px;background:#ef4444;color:white;padding:12px 18px;font-weight:bold;z-index:9999;border-radius:8px;box-shadow:0 4px 15px rgba(239,68,68,0.5);font-family:sans-serif;font-size:14px;';
      document.body.appendChild(toast);
    }
    toast.innerText = `🚨 ANOMALY DETECTED: ${val.toFixed(1)} > 80.0`;
    toast.style.display = 'block';
    clearTimeout(this.toastTimeout);
    this.toastTimeout = setTimeout(() => { toast.style.display = 'none'; }, 2500);
  }

  connectedCallback() {
    this.shadowRoot.innerHTML = `<canvas width="340" height="160" style="background:#0f172a;border:1px solid rgba(255,255,255,0.1);border-radius:8px;display:block;"></canvas>`;
    this.ctx = this.shadowRoot.querySelector('canvas').getContext('2d');
    this.renderChart();
  }

  renderChart() {
    if (!this.ctx) return;
    const w = 340;
    const h = 160;
    this.ctx.clearRect(0, 0, w, h);
    
    // Draw background grid lines
    this.ctx.strokeStyle = 'rgba(255,255,255,0.05)';
    this.ctx.lineWidth = 1;
    for (let y = 32; y < h; y += 32) {
      this.ctx.beginPath();
      this.ctx.moveTo(0, y);
      this.ctx.lineTo(w, y);
      this.ctx.stroke();
    }

    // Draw 80 threshold danger line
    const thresholdY = h - (80 / 100) * h;
    this.ctx.strokeStyle = 'rgba(239, 68, 68, 0.4)';
    this.ctx.setLineDash([4, 4]);
    this.ctx.beginPath();
    this.ctx.moveTo(0, thresholdY);
    this.ctx.lineTo(w, thresholdY);
    this.ctx.stroke();
    this.ctx.setLineDash([]);

    if (this.dataPoints.length < 2) return;

    this.ctx.lineWidth = 2.5;
    for (let i = 1; i < this.dataPoints.length; i++) {
      this.ctx.beginPath();
      let isHigh = this.dataPoints[i] > 80;
      this.ctx.strokeStyle = isHigh ? '#ef4444' : '#00ffa3';
      let prevX = ((i - 1) / 50) * w;
      let prevClamped = Math.max(0, Math.min(100, this.dataPoints[i - 1]));
      let prevY = h - (prevClamped / 100) * h;
      let x = (i / 50) * w;
      let clampedVal = Math.max(0, Math.min(100, this.dataPoints[i]));
      let y = h - (clampedVal / 100) * h;
      this.ctx.moveTo(prevX, prevY);
      this.ctx.lineTo(x, y);
      this.ctx.stroke();
    }
  }

  exportToCsv() {
    const csvContent = "data:text/csv;charset=utf-8,Index,Value,Timestamp\n" + this.dataPoints.map((v, i) => `${i},${v},${new Date().toISOString()}`).join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "yoda_telemetry_export.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
}
customElements.define('live-data-chart', LiveDataChart);
