/**
 * react-catalyst.js
 *
 * LinkedState for Facebook's React UI Library. Add support for
 * deep path state access.
 *
 * Author: Tung Dao <me@tungdao.com>
 *
 * Usage:
 *
 * var WithLink = React.createClass({
 *   mixins: [ReactCatalyst.LinkedStateMixin],
 *   getInitialState: function() {
 *     return { values: [{ text: 'Hello!' }] };
 *   },
 *   render: function() {
 *     return <input type="text" valueLink={this.linkState('values.0.text')} />;
 *   }
 * });
 */

(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define([], factory);
  } else if (typeof exports === 'object') {
    module.exports = factory();
  } else {
    root.ReactCatalyst = factory();
  }
}(this, function () {
  "use strict";

  function getIn(object, path) {
    var stack = path.split('.');
    while (stack.length > 1) {
      object = object[stack.shift()];
    }
    return object[stack.shift()];
  }

  function updateIn(object, path, value) {
    var current = object, stack = path.split('.');
    while (stack.length > 1) {
      current = current[stack.shift()];
    }
    current[stack.shift()] = value;
    return object;
  }

  function setPartialState(component, path, value) {
    component.setState(updateIn(component.state, path, value));
    // HOOKED HERE
    if (component.afterSetPartialState != null) {
      component.afterSetPartialState(path, value)
    };
    // END HOOK
  }

  return {
    LinkedStateMixin: {
      linkState: function(path) {
        return {
          value: getIn(this.state, path),
          requestChange: setPartialState.bind(null, this, path)
        }
      }
    }
  }

}));
