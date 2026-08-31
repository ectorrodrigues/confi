(function ($) {
    'use strict';

    /**
     * ============================================================
     * FORMATAÇÃO DE VALORES
     * ============================================================
     */

    /**
     * Formata valores no padrão brasileiro sem casas decimais.
     */
    function moneyShort(value) {
        value = Number(value) || 0;

        return 'R$ ' + Math.round(value).toLocaleString('pt-BR');
    }

    /**
     * Formata valores no padrão brasileiro com duas casas decimais.
     */
    function moneyFull(value) {
        value = Number(value) || 0;

        return value.toLocaleString('pt-BR', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    /**
     * Formata balanço com sinal.
     *
     * Exemplos:
     * +R$ 1.500,00
     * -R$ 800,00
     */
    function moneyBalance(value) {
        value = Number(value) || 0;

        const signal = value >= 0 ? '+' : '-';

        return signal + 'R$ ' + Math.abs(value).toLocaleString('pt-BR', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    /**
     * ============================================================
     * SEGURANÇA / ESCAPE DE HTML
     * ============================================================
     */

    /**
     * Escapa caracteres HTML.
     */
    function escapeHtml(value) {
        return String(value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    /**
     * Escapa valores utilizados em atributos HTML.
     */
    function escapeAttribute(value) {
        return escapeHtml(value);
    }

    /**
     * ============================================================
     * TIPPY
     * ============================================================
     */

    /**
     * Inicializa os tooltips Tippy nos pontos do gráfico.
     *
     * O Tippy só é inicializado depois que o SVG foi inserido
     * no DOM.
     */
    function initializeTippy($container) {

        // Se o Tippy não estiver carregado, não faz nada.
        if (typeof window.tippy !== 'function') {
            return;
        }

        const elements = $container
            .find('[data-tippy-content]')
            .toArray();

        if (!elements.length) {
            return;
        }

        window.tippy(elements, {
            delay: 0,
            duration: [80, 0],
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
     * Destroi os tooltips Tippy existentes.
     *
     * Isso é necessário quando o gráfico é recriado.
     */
    function destroyTippy($container) {

        if (typeof window.tippy !== 'function') {
            return;
        }

        const elements = $container
            .find('[data-tippy-root], [data-tippy-content]')
            .toArray();

        elements.forEach(function (element) {

            if (element._tippy) {
                element._tippy.destroy();
            }

        });
    }

    /**
     * ============================================================
     * PATH DAS LINHAS
     * ============================================================
     */

    /**
     * Cria um path SVG com os valores do gráfico.
     */
    function createPath(data, key, yFunction, xFunction) {

        return data.map(function (item, index) {

            const value = Number(item[key]) || 0;

            return (
                (index ? 'L' : 'M') +
                ' ' +
                xFunction(index).toFixed(1) +
                ' ' +
                yFunction(value).toFixed(1)
            );

        }).join(' ');
    }

    /**
     * ============================================================
     * RENDERIZAÇÃO DO GRÁFICO
     * ============================================================
     */

    function renderChart() {

        const $el = $('#evolutionChart');

        if (!$el.length) {
            return;
        }

        /*
         * Verifica se os dados existem.
         */
        if (
            !window.confiDashboard ||
            !Array.isArray(window.confiDashboard) ||
            !window.confiDashboard.length
        ) {

            destroyTippy($el);

            $el.empty();

            return;
        }

        const data = window.confiDashboard;

        /**
         * ========================================================
         * DIMENSÕES
         * ========================================================
         */

        const width = Math.max(
            620,
            Math.floor($el.innerWidth())
        );

        const height = 330;

        const pad = {
            l: 55,
            r: 55,
            t: 20,
            b: 55
        };

        const iw = width - pad.l - pad.r;
        const ih = height - pad.t - pad.b;

        /**
         * ========================================================
         * ESCALA ESQUERDA
         *
         * Entradas e Saídas
         * ========================================================
         */

        const maxFlowValue = Math.max(
            1,
            ...data.map(function (item) {

                return Math.max(
                    Number(item.entrada) || 0,
                    Number(item.saida) || 0
                );

            })
        );

        /**
         * Arredonda a escala.
         */
        function niceScale(number) {

            number = Number(number) || 1;

            if (number >= 3000) {
                return Math.ceil(number / 500) * 500;
            }

            return Math.ceil(number / 100) * 100;
        }

        const maxL = niceScale(maxFlowValue);

        /**
         * ========================================================
         * ESCALA DIREITA
         *
         * Balanço.
         *
         * Agora utilizamos o menor e o maior valor REAL.
         * ========================================================
         */

        const balanceValues = data.map(function (item) {
            return Number(item.balanco) || 0;
        });

        /*
         * Menor balanço encontrado.
         */
        const realMinBalance = Math.min(...balanceValues);

        /*
         * Maior balanço encontrado.
         */
        const realMaxBalance = Math.max(...balanceValues);

        /*
         * Arredonda os limites para múltiplos de 100.
         */
        let minB = Math.floor(realMinBalance / 100) * 100;
        let maxB = Math.ceil(realMaxBalance / 100) * 100;

        /*
         * Garante que o zero esteja dentro da escala.
         */
        minB = Math.min(0, minB);
        maxB = Math.max(0, maxB);

        /*
         * Evita intervalo zero.
         */
        if (minB === maxB) {
            minB -= 100;
            maxB += 100;
        }

        /*
         * Intervalo total da escala de balanço.
         */
        const balanceRange = maxB - minB;

        /**
         * ========================================================
         * POSIÇÃO X
         * ========================================================
         */

        function x(index) {

            if (data.length <= 1) {
                return pad.l + (iw / 2);
            }

            return pad.l + (
                iw * (index / (data.length - 1))
            );
        }

        /**
         * ========================================================
         * POSIÇÃO Y - ENTRADA / SAÍDA
         * ========================================================
         *
         * Maior valor → topo
         * Menor valor → base
         */

        function yFlow(value) {

            value = Math.abs(Number(value) || 0);

            return pad.t +
                ih -
                (value / maxL) * ih;
        }

        /**
         * ========================================================
         * POSIÇÃO Y - BALANÇO
         * ========================================================
         *
         * Maior valor → topo
         * Menor valor → base
         */

        function yBalance(value) {

            value = Number(value) || 0;

            return pad.t +
                ((maxB - value) / balanceRange) * ih;
        }

        /**
         * ========================================================
         * DETERMINA QUAL TICK FICA MAIS PRÓXIMO DO ZERO
         * ========================================================
         *
         * Existem 7 marcas:
         *
         * 0 → topo
         * 6 → base
         *
         * Apenas UMA delas será transformada em R$ 0.
         */

        let zeroTickIndex = null;

        let zeroTickDistance = Infinity;

        for (let i = 0; i <= 6; i++) {

            const tickValue =
                maxB -
                (balanceRange * (i / 6));

            const distanceFromZero = Math.abs(tickValue);

            if (distanceFromZero < zeroTickDistance) {

                zeroTickDistance = distanceFromZero;

                zeroTickIndex = i;
            }
        }

        /**
         * ========================================================
         * REMOVE TIPPY ANTES DE RECRIAR O SVG
         * ========================================================
         */

        destroyTippy($el);

        /**
         * ========================================================
         * SVG
         * ========================================================
         */

        let svg = '';

        svg += `
            <svg
                class="chart-svg"
                viewBox="0 0 ${width} ${height}"
                role="img"
                aria-label="Evolução de entradas, saídas e balanço"
            >
        `;

        /**
         * ========================================================
         * GRADE + ESCALAS
         * ========================================================
         */

        for (let i = 0; i <= 6; i++) {

            /*
             * Posição vertical.
             *
             * 0 = topo
             * 6 = base
             */
            const yy =
                pad.t +
                (ih * (i / 6));

            /**
             * ----------------------------------------------------
             * ESCALA ESQUERDA
             * ----------------------------------------------------
             *
             * Maior no topo.
             */
            const left = Math.round(
                maxL * (1 - (i / 6))
            );

            /**
             * ----------------------------------------------------
             * ESCALA DIREITA
             * ----------------------------------------------------
             *
             * Maior no topo.
             * Menor na base.
             */
            const right =
                maxB -
                (balanceRange * (i / 6));

            /**
             * ----------------------------------------------------
             * ZERO
             * ----------------------------------------------------
             *
             * Somente a marca mais próxima de zero recebe
             * "R$ 0".
             *
             * Isso evita:
             *
             * R$ 17
             * R$ 0
             *
             * na mesma posição.
             */
            const rightLabel =
                i === zeroTickIndex
                    ? 'R$ 0'
                    : moneyShort(right);

            /**
             * ----------------------------------------------------
             * LINHA DE GRADE
             * ----------------------------------------------------
             */

            svg += `
                <line
                    x1="${pad.l}"
                    y1="${yy}"
                    x2="${width - pad.r}"
                    y2="${yy}"
                    class="chart-grid"
                />
            `;

            /**
             * ----------------------------------------------------
             * VALOR DA ESCALA ESQUERDA
             * ----------------------------------------------------
             */

            svg += `
                <text
                    x="8"
                    y="${yy + 4}"
                    class="axis-label"
                >
                    ${escapeHtml(moneyShort(left))}
                </text>
            `;

            /**
             * ----------------------------------------------------
             * VALOR DA ESCALA DIREITA
             * ----------------------------------------------------
             */

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

        /**
         * ========================================================
         * MESES
         * ========================================================
         */

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

        /**
         * ========================================================
         * LINHA DE SAÍDAS
         * ========================================================
         */

        svg += `
            <path
                d="${createPath(
                    data,
                    'saida',
                    yFlow,
                    x
                )}"
                class="chart-line line-out"
            />
        `;

        /**
         * ========================================================
         * LINHA DE ENTRADAS
         * ========================================================
         */

        svg += `
            <path
                d="${createPath(
                    data,
                    'entrada',
                    yFlow,
                    x
                )}"
                class="chart-line line-in"
            />
        `;

        /**
         * ========================================================
         * LINHA DE BALANÇO
         * ========================================================
         */

        svg += `
            <path
                d="${createPath(
                    data,
                    'balanco',
                    yBalance,
                    x
                )}"
                class="chart-line line-bal"
            />
        `;

        /**
         * ========================================================
         * PONTOS DO GRÁFICO
         * ========================================================
         */

        data.forEach(function (item, index) {

            const saida =
                Number(item.saida) || 0;

            const entrada =
                Number(item.entrada) || 0;

            const balanco =
                Number(item.balanco) || 0;

            const label =
                item.label || '';

            /**
             * ----------------------------------------------------
             * PONTO DE SAÍDA
             * ----------------------------------------------------
             */

            svg += `
                <circle
                    cx="${x(index)}"
                    cy="${yFlow(saida)}"
                    r="4"
                    class="point-out"
                    data-tippy-content="${escapeAttribute(
                        label +
                        ' — Saídas: R$ ' +
                        moneyFull(saida)
                    )}"
                    tabindex="0"
                    aria-label="${escapeAttribute(
                        label +
                        ' — Saídas: R$ ' +
                        moneyFull(saida)
                    )}"
                ></circle>
            `;

            /**
             * ----------------------------------------------------
             * PONTO DE ENTRADA
             * ----------------------------------------------------
             */

            svg += `
                <circle
                    cx="${x(index)}"
                    cy="${yFlow(entrada)}"
                    r="4"
                    class="point-in"
                    data-tippy-content="${escapeAttribute(
                        label +
                        ' — Entradas: R$ ' +
                        moneyFull(entrada)
                    )}"
                    tabindex="0"
                    aria-label="${escapeAttribute(
                        label +
                        ' — Entradas: R$ ' +
                        moneyFull(entrada)
                    )}"
                ></circle>
            `;

            /**
             * ----------------------------------------------------
             * PONTO DE BALANÇO
             * ----------------------------------------------------
             */

            svg += `
                <circle
                    cx="${x(index)}"
                    cy="${yBalance(balanco)}"
                    r="4"
                    class="point-bal"
                    data-tippy-content="${escapeAttribute(
                        label +
                        ' — Balanço: ' +
                        moneyBalance(balanco)
                    )}"
                    tabindex="0"
                    aria-label="${escapeAttribute(
                        label +
                        ' — Balanço: ' +
                        moneyBalance(balanco)
                    )}"
                ></circle>
            `;
        });

        /**
         * Fecha o SVG.
         */
        svg += '</svg>';

        /**
         * ========================================================
         * INSERE O SVG NO DOM
         * ========================================================
         *
         * É somente depois desta etapa que os elementos dos
         * pontos existem no DOM.
         */

        $el.html(svg);

        /**
         * ========================================================
         * INICIALIZA O TIPPY
         * ========================================================
         */

        initializeTippy($el);
    }

    /**
     * ============================================================
     * RESIZE
     * ============================================================
     */

    let resizeTimer = null;

    $(window).on('resize', function () {

        clearTimeout(resizeTimer);

        resizeTimer = setTimeout(function () {

            renderChart();

        }, 100);
    });

    /**
     * ============================================================
     * INICIALIZAÇÃO
     * ============================================================
     */

    $(function () {

        renderChart();

    });

})(jQuery);