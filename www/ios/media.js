var exec = require('cordova/exec');

module.exports = {
  "request" : function(next) {
    exec(function(granted) { next(granted); }, null, 'JDMedia', 'microphone');
  },
  "play" : function() { exec(null, null, 'JDMedia', 'play'); },
  "pause" : function() { exec(null, null, 'JDMedia', 'pause'); },
  "record" : function() { exec(null, null, 'JDMedia', 'record'); },
  "stopRecording" : function() {
    exec(null, null, 'JDMedia', 'stopRecording');
  },
  "clear" : function(next) { exec(null, null, 'JDMedia', 'clear'); }
};
