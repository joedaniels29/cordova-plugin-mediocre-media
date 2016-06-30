# Microphone

```bash
cordova plugin install com.d29.cordova.microphone
```

```JavaScript
navigator.jdmedia.microphone(function (on) {
  if (on) {
    // now you can use the Cordova media plugin to record
  }
  else {
    // instruct how to enable your app's access to the microphone
  }
});
```
###Heres how you work it

*note. All this stuff runs on the main thread. Not sure if thats what you should do.... but thats what I'm doing*

```JavaScript
// Record and finish recording.
navigator.jdmedia.record()
navigator.jdmedia.stopRecording()
// Play the file you just created
navigator.jdmedia.play()
// pause. hitting play again is a resume.
navigator.jdmedia.pause()
//Delete file you just created
navigator.jdmedia.clear()
```


#Contributing
Yeah, sure. why not? submit a pr. 
