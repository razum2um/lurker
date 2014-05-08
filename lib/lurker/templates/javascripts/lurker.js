var window = this.window;
var $ = window.$;
var Lurker = {

  disableSubmitButton: function() {
    $("#submit-api").attr("disabled", true);
  },

  enableSubmitButton: function() {
    $("#submit-api").attr("disabled", false);
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
    $tab.find('#headers').text(xhr.getAllResponseHeaders());

    var realTimeTaken = Lurker.lastRequest.endTime - Lurker.lastRequest.startTime;
    $tab.find('.time td.value').text(realTimeTaken + " ms");
  },

  fillInRawTab: function($tab, xhr) {
    switch (Lurker.detectContentType(xhr)) {
      case "json":
        var json = JSON.stringify(JSON.parse(xhr.responseText), null, 2);
        var content = hljs.highlightAuto(json).value;
        break;
      default:
        var content = xhr.responseText;
    }
    $tab.html(content);
  },

  onComplete: function(xhr) {
    Lurker.lastRequest.endTime = Date.now();
    Lurker.enableSubmitButton();

    $("#show-api-response-div [ref^='response']").hide();

    Lurker.fillInInfoTab($("#show-api-response-div").showNavTab("info"), xhr);
    Lurker.fillInRawTab($("#show-api-response-div").showNavTab("raw"), xhr);
  },

  onSubmit: function($form) {
    Lurker.disableSubmitButton();

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

