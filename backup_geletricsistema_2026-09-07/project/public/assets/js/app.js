$(function () {
  $('.password-toggle').on('click', function () {
    const input = $(this).siblings('input');
    const showing = input.attr('type') === 'text';
    input.attr('type', showing ? 'password' : 'text');
    $(this).find('i').toggleClass('fa-eye fa-eye-slash');
  });

  function syncCreditFields() {
    const isCredit = $('#payment_method').val() === 'Cartão de Crédito';
    $('.credit-fields').toggleClass('is-visible', isCredit);
    $('#status').prop('disabled', isCredit);
    if (isCredit) $('#status').val('Pendente');
  }
  $('#payment_method').on('change', syncCreditFields);
  syncCreditFields();

  $('input[name="amount"]').on('blur', function () {
    let raw = String($(this).val()).replace(/[^0-9,.-]/g, '');
    if (raw.includes(',')) raw = raw.replace(/\./g, '').replace(',', '.');
    if (raw !== '' && !Number.isNaN(Number(raw))) {
      $(this).val(Number(raw).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
    }
  });

  $('#phone').on('input', function () {
    let value = $(this).val().replace(/\D/g, '').slice(0, 11);
    if (value.length <= 10) value = value.replace(/(\d{2})(\d)/, '($1) $2').replace(/(\d{4})(\d)/, '$1-$2');
    else value = value.replace(/(\d{2})(\d)/, '($1) $2').replace(/(\d{5})(\d)/, '$1-$2');
    $(this).val(value);
  });
});

  function loadCities(keepSelected) {
    const $state = $('#state');
    const $city = $('#city');
    const $loading = $('#city-loading');
    if (!$state.length || !$city.length) return;
    const uf = $state.val();
    const selected = keepSelected ? String($city.data('selected-city') || $city.val() || '') : '';
    $city.prop('disabled', true).html('<option value="">Carregando cidades...</option>');
    if ($loading.length) $loading.text('');

    function renderCities(cities) {
      const list = Array.isArray(cities) ? cities : [];
      $city.empty().append('<option value="">Selecione uma cidade</option>');
      list.forEach(function (city) {
        const name = city && city.nome ? city.nome : (typeof city === 'string' ? city : '');
        if (!name) return;
        const option = $('<option>').val(name).text(name);
        if (name === selected) option.prop('selected', true);
        $city.append(option);
      });
      $city.prop('disabled', false);
      $city.removeData('selected-city');
    }

    $.getJSON('api/cidades?uf=' + encodeURIComponent(uf))
      .done(function (cities) {
        renderCities(cities);
      })
      .fail(function () {
        $.getJSON('https://servicodados.ibge.gov.br/api/v1/localidades/estados/' + encodeURIComponent(uf) + '/municipios')
          .done(function (cities) {
            renderCities(cities);
          })
          .fail(function () {
            $city.html('<option value="">Não foi possível carregar as cidades</option>').prop('disabled', false);
            if ($loading.length) $loading.text('Verifique a conexão com a internet e tente novamente.');
          });
      });
  }

  $('#state').on('change', function () {
    $('#city').removeData('selected-city').data('selected-city', '');
    loadCities(false);
  });
  if ($('#state').length && $('#city').length) loadCities(true);

