(function() {
  var $ = window.jQuery;
  var hljs = window.hljs;

  var Lurker = {
    disableSubmitButton: function() {
      $("#submit-api").attr("disabled", true);
    },

    enableSubmitButton: function() {
      $("#submit-api").attr("disabled", false);
    },

    fillInInfoTab: function($tab, xhr) {
      $tab.find('.status td.value').text(xhr.status + " " + xhr.statusText);
      $tab.find('#headers').text(xhr.getAllResponseHeaders());

      var realTimeTaken = Lurker.lastRequest.endTime - Lurker.lastRequest.startTime;
      $tab.find('.time td.value').text(realTimeTaken + " ms");
    },

    fillInRawTab: function($tab, xhr) {
      var content;
      switch (Lurker.detectContentType(xhr)) {
        case "json":
          var json = JSON.stringify(JSON.parse(xhr.responseText), null, 2);
          content = hljs.highlightAuto(json).value;
          break;
        default:
          content = xhr.responseText;
      }
      $tab.html(content);
    },

    detectContentType: function(response) {
      var contentType = response.getResponseHeader("Content-Type");
      var detectedContentType = null;

      if (contentType.match(/application\/json/)) {
        detectedContentType = 'json';
      }

      return detectedContentType;
    },

    buildActionUrl: function(host, template, values) {
      for (var i = 0; i < values.length; i++) {
        var placeholder = new RegExp(':' + values[i].label);
        template = template.replace(placeholder, encodeURIComponent(values[i].value));
      }
      return host + template;
    },

    serializePayload: function(payload, contentType) {
      if (contentType === 'application/json' || /\+json$/.test(contentType)) {
        return JSON.stringify(payload);
      } else {
        // default to 'application/x-www-form-urlencoded'
        return jQuery.param(payload);
      }
    },

    generateCurlCommand: function(targetUrl, method, payload, contentType) {
      var serializedPayload = Lurker.serializePayload(payload, contentType);
      var results = [];
      results.push('curl');
      results.push('-X ' + method);
      if (serializedPayload.length > 0) {
        if (contentType != 'application/x-www-form-urlencoded') {
          results.push("-H 'Content-Type: " + contentType + "'");
        }
        results.push("-d '" + serializedPayload + "'");
      }
      results.push("'" + targetUrl + "'");
      return results.join(' ');
    },

    performRequest: function(host, method, template, values, payload, contentType) {
      Lurker.disableSubmitButton();

      $.ajax({
        url: Lurker.buildActionUrl(host, template, values),
        data: Lurker.serializePayload(payload, contentType),
        method: method,
        contentType: contentType,
        processData: false
      }).complete(Lurker.onComplete);

      Lurker.lastRequest = {};
      Lurker.lastRequest.startTime = Date.now();

      return false;
    },

    onComplete: function(xhr) {
      Lurker.lastRequest.endTime = Date.now();
      Lurker.enableSubmitButton();

      var $responseDiv = $("#show-api-response-div");
      $responseDiv.find("[ref^='response']").hide();

      Lurker.fillInInfoTab($responseDiv.showNavTab("info"), xhr);
      Lurker.fillInRawTab($responseDiv.showNavTab("raw"), xhr);
    }
  };

  window.Lurker = Lurker;

  $(function($) {
    var activeMenuItem = $('#side-menu').find('a[href="' + window.location.pathname + '"]');
    if (activeMenuItem.length === 1) {
      activeMenuItem.addClass('hovered')
          .parents('.collapse').addClass('in')
          .parents('.endpoint-group').addClass('active');
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
    }
  });
})();

