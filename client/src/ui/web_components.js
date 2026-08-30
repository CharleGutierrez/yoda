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
    let rows = [];
    try {
      const parsed = JSON.parse(this.getAttribute('data') || '[]');
      rows = Array.isArray(parsed) ? parsed : [parsed];
    } catch(e) {
      rows = [{field1: 'No Data', field2: 'No Data', field3: 'No Data'}];
    }
    
    const rowHtml = rows.map(r => {
        let isAnomaly = (parseFloat(r.field1) > 80) || (parseFloat(r.field2) > 80) || (parseFloat(r.field3) > 80);
        let bg = isAnomaly ? 'background: rgba(255,0,0,0.5);' : '';
        return `
        <div class="cell" style="${bg}">${r.field1 !== undefined ? r.field1 : 'N/A'}</div>
        <div class="cell" style="${bg}">${r.field2 !== undefined ? r.field2 : 'N/A'}</div>
        <div class="cell" style="${bg}">${r.field3 !== undefined ? r.field3 : 'N/A'}</div>
        `;
    }).join('');

    this.shadowRoot.innerHTML = `
      <style>
        .grid {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 10px;
          border: 1px solid #ccc;
          padding: 10px;
          background: rgba(0, 0, 0, 0.5);
          color: white;
        }
        .cell {
          padding: 5px;
          border: 1px solid #555;
        }
      </style>
      <div class="grid">
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
    let events = [];
    try {
      const parsed = JSON.parse(this.getAttribute('event-text') || '[]');
      events = Array.isArray(parsed) ? parsed : [{title: parsed.title || this.getAttribute('event-text')}];
    } catch(e) {
      events = [{title: this.getAttribute('event-text') || 'No Event'}];
    }
    
    const eventsHtml = events.map(e => `<p>Event: ${e.title !== undefined ? e.title : e}</p>`).join('');

    this.shadowRoot.innerHTML = `
      <style>
        .calendar {
          border: 1px solid #ccc;
          padding: 10px;
          background: rgba(0, 0, 0, 0.5);
          color: white;
        }
      </style>
      <div class="calendar">
        <p>Live Real-Time Calendar View</p>
        ${eventsHtml}
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
      let num = 0;
      try {
        const parsed = JSON.parse(newVal);
        num = parsed.value || 0;
      } catch (e) {
        num = parseFloat(newVal.replace(/[^0-9.]/g, '')) || 0;
      }
      this.dataPoints.push(num);
      if (this.dataPoints.length > 50) this.dataPoints.shift();
      if (num > 80) this.showAnomalyToast();
      this.renderChart();
    }
  }
  showAnomalyToast() {
    let toast = document.getElementById('anomaly-toast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'anomaly-toast';
      toast.style.cssText = 'position:fixed;top:20px;right:20px;background:red;color:white;padding:15px;font-weight:bold;z-index:9999;border-radius:5px;box-shadow:0 0 10px rgba(255,0,0,0.5);';
      toast.innerText = 'ANOMALY DETECTED';
      document.body.appendChild(toast);
    }
    toast.style.display = 'block';
    clearTimeout(this.toastTimeout);
    this.toastTimeout = setTimeout(() => { toast.style.display = 'none'; }, 2000);
  }
  connectedCallback() {
    this.shadowRoot.innerHTML = `<canvas width="300" height="150" style="background:#1a1a1a;border:1px solid #333;"></canvas>`;
    this.ctx = this.shadowRoot.querySelector('canvas').getContext('2d');
  }
  renderChart() {
    if (!this.ctx) return;
    this.ctx.clearRect(0, 0, 300, 150);
    this.ctx.lineWidth = 2;
    for (let i = 1; i < this.dataPoints.length; i++) {
      this.ctx.beginPath();
      this.ctx.strokeStyle = this.dataPoints[i] > 80 ? 'red' : '#00ffcc';
      let prevX = ((i - 1) / 50) * 300;
      let prevClamped = Math.max(0, Math.min(100, this.dataPoints[i - 1]));
      let prevY = 150 - (prevClamped / 100) * 150;
      let x = (i / 50) * 300;
      let clampedVal = Math.max(0, Math.min(100, this.dataPoints[i]));
      let y = 150 - (clampedVal / 100) * 150;
      this.ctx.moveTo(prevX, prevY);
      this.ctx.lineTo(x, y);
      this.ctx.stroke();
    }
  }
  exportToCsv() {
    const csvContent = "data:text/csv;charset=utf-8,Index,Value\n" + this.dataPoints.map((v, i) => `${i},${v}`).join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "yoda_data_export.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
}
customElements.define('live-data-chart', LiveDataChart);

