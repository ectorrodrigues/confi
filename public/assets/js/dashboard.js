(function ($) {
  function moneyShort(value) {
    return 'R$ ' + Math.round(value).toLocaleString('pt-BR');
  }
  function renderChart() {
    const $el = $('#evolutionChart');
    if (!$el.length || !window.confiDashboard || !window.confiDashboard.length) return;
    const data = window.confiDashboard;
    const width = Math.max(620, $el.innerWidth());
    const height = 330;
    const pad = { l: 55, r: 55, t: 20, b: 55 };
    const iw = width - pad.l - pad.r;
    const ih = height - pad.t - pad.b;
    const maxFlow = Math.max(1, ...data.map(d => Math.max(Number(d.entrada), Number(d.saida))));
    const maxBal = Math.max(1, ...data.map(d => Math.abs(Number(d.balanco))));
    const nice = (n) => Math.ceil(n / (n >= 3000 ? 500 : 100)) * (n >= 3000 ? 500 : 100);
    const maxL = nice(maxFlow);
    const maxB = nice(maxBal);
    const x = i => pad.l + iw * (i / (data.length - 1));
    const yFlow = v => pad.t + ih - (Math.abs(v) / maxL) * ih;
    const yBal = v => pad.t + ih - (Math.abs(v) / maxB) * ih;
    const path = (key, yFn) => data.map((d, i) => `${i ? 'L' : 'M'} ${x(i).toFixed(1)} ${yFn(Number(d[key])).toFixed(1)}`).join(' ');

    let svg = `<svg class="chart-svg" viewBox="0 0 ${width} ${height}" role="img" aria-label="Evolução de entradas, saídas e balanço">`;
    for (let i = 0; i <= 6; i++) {
      const yy = pad.t + ih - ih * (i / 6);
      const left = Math.round(maxL * i / 6);
      const right = Math.round(maxB * i / 6);
      svg += `<line x1="${pad.l}" y1="${yy}" x2="${width - pad.r}" y2="${yy}" class="chart-grid"/>`;
      svg += `<text x="8" y="${yy + 4}" class="axis-label">${moneyShort(left)}</text>`;
      svg += `<text x="${width - pad.r + 8}" y="${yy + 4}" class="axis-label right">${moneyShort(right)}</text>`;
    }
    data.forEach((d, i) => {
      svg += `<text x="${x(i)}" y="${height - 18}" class="axis-label month" text-anchor="middle">${d.label}</text>`;
    });
    svg += `<path d="${path('saida', yFlow)}" class="chart-line line-out"/>`;
    svg += `<path d="${path('entrada', yFlow)}" class="chart-line line-in"/>`;
    svg += `<path d="${path('balanco', yBal)}" class="chart-line line-bal"/>`;
    data.forEach((d, i) => {
      svg += `<circle cx="${x(i)}" cy="${yFlow(Number(d.saida))}" r="3.3" class="point-out"/>`;
      svg += `<circle cx="${x(i)}" cy="${yFlow(Number(d.entrada))}" r="3.3" class="point-in"/>`;
      svg += `<circle cx="${x(i)}" cy="${yBal(Number(d.balanco))}" r="3.3" class="point-bal"/>`;
    });
    svg += '</svg>';
    $el.html(svg);
  }
  $(window).on('resize', renderChart);
  renderChart();
})(jQuery);
