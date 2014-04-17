var window = this.window;
var $ = window.$;
var Lurker = {

  disableSubmitButton: function() {
    $("#submit-api").attr("disabled", true);
  },

  enableSubmitButton: function() {
    $("#submit-api").attr("disabled", false);
  },

  disableUrlParams: function() {
    $("fieldset[ref=url-params] input").prop("disabled", true);
  },

  enableUrlParams: function() {
    $("fieldset[ref=url-params] input").prop("disabled", false);
  },

  detectContentType: function(response) {
    var contentType = response.getResponseHeader("Content-Type");
    var detectedContentType = null;

    if (contentType.match(/application\/json/)) {
       detectedContentType = 'json';
    }

    return detectedContentType;
  },

  fillInInfoTab: function($tab, xhr) {
    $tab.find('.status td.value').text(xhr.status + " " + xhr.statusText);
    $tab.find('.headers td.value').text(xhr.getAllResponseHeaders());

    var realTimeTaken = Lurker.lastRequest.endTime - Lurker.lastRequest.startTime;
    $tab.find('.time td.value').text(realTimeTaken + " ms");
  },

  getSubmitUrl: function($form) {
    var baseUrl = $form.attr('action');
    var matches = baseUrl.match(/\:[^\/]+/g);
    var a, match, str, input;

    if (matches) {
      for(a = 0; a < matches.length; a++) {
        match = matches[a];
        str = match.substr(1);

        input = $form.find(
          'input[name="' + str + '"],input[name="[_url_params]' + str + '"]'
        );

        if (input.length > 0) {
          baseUrl = baseUrl.replace(match, input.val());
        }
      }
    }

    var query = $('form#query').serialize();
    return (window.domain || '/').replace(/\/$/, '') + '/' + baseUrl.replace(/^\//, '') + '?' + query;
  }

};

$.fn.extend({
  showNavTab: function(name) {
    return $(this).find("[ref=response-" + name + "]").show();
  },
});

$(function($) {

  var onComplete = function(xhr) {
    Lurker.lastRequest.endTime = Date.now();
    Lurker.enableSubmitButton();
    Lurker.enableUrlParams();

    if ($("#show-api-response-div:visible").length === 0) {
      $("#show-api-response-div").slideDown(100);
    }

    Lurker.fillInInfoTab(
      $("#show-api-response-div").showNavTab("info"),
      xhr
    );

    $("#show-api-response-div pre").hide();
    switch (Lurker.detectContentType(xhr)) {
      case "json":
        $("#show-api-response-div").showNavTab("json").text(
          JSON.stringify(JSON.parse(xhr.responseText), null, 2)
        );
        break;
      default:
        $("#show-api-response-div").showNavTab('raw').text(xhr.responseText);
    }

    window.prettyPrint();
  };

  var $form;
  var onSubmit = function(e) {
    $form = $(e.target);
    Lurker.disableSubmitButton();
    Lurker.disableUrlParams();

    window.ajax = $.ajax({
      url: Lurker.getSubmitUrl($form),
      method: $form.attr('method'),
      data: $form.serialize()
    }).complete(onComplete);

    Lurker.lastRequest = {};
    Lurker.lastRequest.startTime = Date.now();

    return false;
  };

  window.prettyPrint();

  $("form#payload").submit(onSubmit);

  var activeMenuItem = $('#side-menu a[href="' + window.location.pathname + '"]');
  if (activeMenuItem.length === 1) {
    activeMenuItem.addClass('hovered').parents('.collapse').addClass('in').parents('.endpoint-group').addClass('active');
  }

  window.domain = window.localStorage.lastDomain || '/';
  function currentDomain(domain) {
    $('.domains').find('.current')
      .text($(this).text() + " (" + domain + ")")
      .data('domain', domain);
  }

  $('.domains .domain').click(function() {
    window.domain = window.localStorage.lastDomain = $(this).data('domain');
    currentDomain(window.domain);
  });

  $('.domains .current.btn').click(function() {
    window.location = $(this).data('domain');
  });
  currentDomain(window.domain);
});
