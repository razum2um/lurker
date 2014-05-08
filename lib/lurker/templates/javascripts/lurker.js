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

  onComplete: function(xhr) {
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

    //$("#show-api-response-div [ref^='response']").hide();
    switch (Lurker.detectContentType(xhr)) {
      case "json":
        $("#show-api-response-div").showNavTab("json").text(xhr.responseText);
        //$("#show-api-response-div").showNavTab("json").text(
        //  JSON.stringify(JSON.parse(xhr.responseText), null, 2)
        //);
        break;
      default:
        $("#show-api-response-div").showNavTab('raw').text(xhr.responseText);
    }
    $('#show-api-response-div .prettyprint').each(function(i, e) {hljs.highlightBlock(e)});

    //window.prettyPrint();
  },

  onSubmit: function($form) {
    Lurker.disableSubmitButton();
    Lurker.disableUrlParams();

    $.ajax({
      url: $form.attr('action'),
      method: $form.attr('method'),
      data: $form.serialize()
    }).complete(Lurker.onComplete);

    Lurker.lastRequest = {};
    Lurker.lastRequest.startTime = Date.now();

    return false;
  }
};

$(function($) {
  //window.prettyPrint();

  var activeMenuItem = $('#side-menu a[href="' + window.location.pathname + '"]');
  if (activeMenuItem.length === 1) {
    activeMenuItem.addClass('hovered').parents('.collapse').addClass('in').parents('.endpoint-group').addClass('active');
  }

  window.domain = window.localStorage.lastDomain || '/';
  window.domainName = window.localStorage.lastDomainName || 'Local';
  function currentDomain(domain, domainName) {
    $('.domains').find('.current')
      .text(domainName)
      .data('domain', domain);
  }

  $('.domains .domain').click(function() {
    window.domain = window.localStorage.lastDomain = $(this).data('domain');
    window.domainName = window.localStorage.lastDomainName = $(this).text() + " (" + window.domain + ")";
    currentDomain(window.domain, window.domainName);
  });

  $('.domains .current.btn').click(function() {
    window.location = $(this).data('domain');
  });
  currentDomain(window.domain, window.domainName);
});

$.fn.extend({
  showNavTab: function(name) {
    return $(this).find("[ref=response-" + name + "]").show();
  },
});

