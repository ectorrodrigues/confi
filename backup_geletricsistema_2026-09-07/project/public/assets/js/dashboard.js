(function ($) {
  'use strict';

  function moneyShort(value) {
    return 'R$ ' + Math.round(Number(value) || 0).toLocaleString('pt-BR');
  }

  function moneyFull(value) {
    return (Number(value) || 0).toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });
  }

  function moneyBalance(value) {
    value = Number(value) || 0;
    const signal = value >= 0 ? '+' : '-';

    return signal + 'R$ ' + Math.abs(value).toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  function escapeAttribute(value) {
    return escapeHtml(value);
  }

  /**
   * Inicializa os tooltips Tippy depois que o SVG já foi inserido no DOM.
   */
  function initializeTippy($container) {
    if (typeof window.tippy !== 'function') {
      return;
    }

    const elements = $container.find('[data-tippy-content]').toArray();

    if (!elements.length) {
      return;
    }

    window.tippy(elements, {
      delay: 0,
      duration: [60, 0],
      animation: 'shift-away',
      placement: 'top',
      arrow: true,
      followCursor: false,
      interactive: false,
      hideOnClick: false,
      touch: false,
      popperOptions: {
        modifiers: [
          {
            name: 'offset',
            options: {
              offset: [0, 8]
            }
          }
        ]
      }
    });
  }

  /**
   * Destrói instâncias Tippy existentes antes de recriar o gráfico.
   */
  function destroyTippy($container) {
    if (typeof window.tippy !== 'function') {
      return;
    }

    $container.find('[data-tippy-content]').each(function () {
      if (this._tippy) {
        this._tippy.destroy();
      }
    });
  }

  function createPath(data, key, yFunction, xFunction) {
    return data.map(function (item, index) {
      const value = Number(item[key]) || 0;

      return (
        (index ? 'L' : 'M') + ' ' +
        xFunction(index).toFixed(1) + ' ' +
        yFunction(value).toFixed(1)
      );
    }).join(' ');
  }

  function renderChart() {
    const $el = $('#evolutionChart');

    if (!$el.length) {
      return;
    }

    if (!window.confiDashboard || !Array.isArray(window.confiDashboard) || !window.confiDashboard.length) {
      destroyTippy($el);
      $el.empty();
      return;
    }

    const data = window.confiDashboard;

    const width = Math.max(620, Math.floor($el.innerWidth()));
    const height = 330;
    const pad = { l: 55, r: 55, t: 20, b: 55 };
    const iw = width - pad.l - pad.r;
    const ih = height - pad.t - pad.b;

    /* Escala esquerda: entradas e saídas. */
    const maxFlowValue = Math.max(
      1,
      ...data.map(function (item) {
        return Math.max(
          Number(item.entrada) || 0,
          Number(item.saida) || 0
        );
      })
    );

    function niceScale(number) {
      number = Number(number) || 1;

      if (number >= 3000) {
        return Math.ceil(number / 500) * 500;
      }

      return Math.ceil(number / 100) * 100;
    }

    const maxL = niceScale(maxFlowValue);

    /* Escala direita: balanço, com mínimo e máximo reais. */
    const balanceValues = data.map(function (item) {
      return Number(item.balanco) || 0;
    });

    const realMinBalance = Math.min(...balanceValues);
    const realMaxBalance = Math.max(...balanceValues);

    let minB = Math.floor(realMinBalance / 100) * 100;
    let maxB = Math.ceil(realMaxBalance / 100) * 100;

    minB = Math.min(0, minB);
    maxB = Math.max(0, maxB);

    if (minB === maxB) {
      minB -= 100;
      maxB += 100;
    }

    const balanceRange = maxB - minB;

    const x = function (index) {
      if (data.length <= 1) {
        return pad.l + (iw / 2);
      }

      return pad.l + (iw * (index / (data.length - 1)));
    };

    const yFlow = function (value) {
      value = Math.abs(Number(value) || 0);

      return pad.t + ih - (value / maxL) * ih;
    };

    const yBalance = function (value) {
      value = Number(value) || 0;

      return pad.t + ((maxB - value) / balanceRange) * ih;
    };

    /*
     * Escolhe uma única marca da escala mais próxima do zero.
     * Essa marca será exibida como R$ 0, evitando sobreposição.
     */
    let zeroTickIndex = null;
    let zeroTickDistance = Infinity;

    for (let i = 0; i <= 6; i++) {
      const tickValue = maxB - (balanceRange * (i / 6));
      const distanceFromZero = Math.abs(tickValue);

      if (distanceFromZero < zeroTickDistance) {
        zeroTickDistance = distanceFromZero;
        zeroTickIndex = i;
      }
    }

    destroyTippy($el);

    let svg = `
      <svg
        class="chart-svg"
        viewBox="0 0 ${width} ${height}"
        role="img"
        aria-label="Evolução de entradas, saídas e balanço"
      >
    `;

    /* Grade e escalas. */
    for (let i = 0; i <= 6; i++) {
      /* i=0 é topo; i=6 é base. */
      const yy = pad.t + ih * (i / 6);

      /* Maior valor no topo e zero embaixo. */
      const left = Math.round(maxL * (1 - (i / 6)));

      /* Maior balanço no topo e menor balanço na base. */
      const right = maxB - (balanceRange * (i / 6));

      /* Uma única marca recebe o rótulo zero. */
      const rightLabel = i === zeroTickIndex ? 'R$ 0' : moneyShort(right);

      svg += `
        <line
          x1="${pad.l}"
          y1="${yy}"
          x2="${width - pad.r}"
          y2="${yy}"
          class="chart-grid"
        />
      `;

      svg += `
        <text
          x="8"
          y="${yy + 4}"
          class="axis-label"
        >
          ${escapeHtml(moneyShort(left))}
        </text>
      `;

      svg += `
        <text
          x="${width - pad.r + 8}"
          y="${yy + 4}"
          class="axis-label right"
        >
          ${escapeHtml(rightLabel)}
        </text>
      `;
    }

    /* Meses no eixo X. */
    data.forEach(function (item, index) {
      svg += `
        <text
          x="${x(index)}"
          y="${height - 18}"
          class="axis-label month"
          text-anchor="middle"
        >
          ${escapeHtml(item.label || '')}
        </text>
      `;
    });

    /* Linhas. */
    svg += `
      <path
        d="${createPath(data, 'saida', yFlow, x)}"
        class="chart-line line-out"
      />
    `;

    svg += `
      <path
        d="${createPath(data, 'entrada', yFlow, x)}"
        class="chart-line line-in"
      />
    `;

    svg += `
      <path
        d="${createPath(data, 'balanco', yBalance, x)}"
        class="chart-line line-bal"
      />
    `;

    /* Pontos com dados para o Tippy. */
    data.forEach(function (item, index) {
      const saida = Number(item.saida) || 0;
      const entrada = Number(item.entrada) || 0;
      const balanco = Number(item.balanco) || 0;
      const label = item.label || '';

      svg += `
        <circle
          cx="${x(index)}"
          cy="${yFlow(saida)}"
          r="4"
          class="point-out"
          data-tippy-content="${escapeAttribute(
            label + ' — Saídas: R$ ' + moneyFull(saida)
          )}"
          tabindex="0"
          aria-label="${escapeAttribute(
            label + ' — Saídas: R$ ' + moneyFull(saida)
          )}"
        ></circle>
      `;

      svg += `
        <circle
          cx="${x(index)}"
          cy="${yFlow(entrada)}"
          r="4"
          class="point-in"
          data-tippy-content="${escapeAttribute(
            label + ' — Entradas: R$ ' + moneyFull(entrada)
          )}"
          tabindex="0"
          aria-label="${escapeAttribute(
            label + ' — Entradas: R$ ' + moneyFull(entrada)
          )}"
        ></circle>
      `;

      svg += `
        <circle
          cx="${x(index)}"
          cy="${yBalance(balanco)}"
          r="4"
          class="point-bal"
          data-tippy-content="${escapeAttribute(
            label + ' — Balanço: ' + moneyBalance(balanco)
          )}"
          tabindex="0"
          aria-label="${escapeAttribute(
            label + ' — Balanço: ' + moneyBalance(balanco)
          )}"
        ></circle>
      `;
    });

    svg += '</svg>';

    /* Primeiro insere o SVG no DOM. */
    $el.html(svg);

    /* Depois inicializa o Tippy nos pontos recém-criados. */
    initializeTippy($el);
  }

  let resizeTimer = null;

  $(window).on('resize', function () {
    clearTimeout(resizeTimer);

    resizeTimer = setTimeout(function () {
      renderChart();
    }, 100);
  });

  $(function () {
    renderChart();
  });
})(jQuery);
