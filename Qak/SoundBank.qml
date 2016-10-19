import QtQuick 2.0
import QtMultimedia 5.4

import Qak 1.0
import Qak.Tools 1.0

import "."

import "../utility.js" as Utility

Item {
    id: soundBank

    property var incubator: Incubator.get()
    property var bank: ({})

    readonly property int infinite: SoundEffect.Infinite
    property int loops: 0
    //property int count: 0

    property bool muted: false
    property real volume: 1

    signal loaded (string tag, var sound)
    signal error (string errorMessage)

    signal playing (string tag, var sound)

    onMutedChanged: mute(muted)

    Component.onDestruction: clear()

    function add(tag, path) {

        if(tag === '') {
            App.warn('SoundBank','Tag is empty for sound "'+path+'". Not added...')
            return
        }

        if(!Qak.resource.exists(path)) {
            App.warn('SoundBank','Seems like',path,'sound file doesn\'t exist? Not added...')
            return
        }

        if(tag in bank) {
            var sound = bank[tag]
            if('source' in sound) {
                if(sound.source === path) {
                    //App.info('SoundBank','Skipping',tag,'with sound',path,'it\'s already added')
                    return
                } else
                    App.info('SoundBank','Updating',tag,'from',sound.source,'to',path)
            }
        }

        var attributes = {
            tag: tag,
            source: path
        }

        try {
            incubator.now(soundEffectComponent, soundBank, attributes, function(obj){
                registerSoundReady(obj)
            })
        } catch(e) {
            error(e)
        }

    }

    function get(tag) {
        if(tag in bank) {
            var sound = bank[tag]
            if(sound)
                return sound
        }
    }

    Component {
        id: soundEffectComponent
        SoundEffect {
            id: soundEffect
            muted: false
            volume: soundBank.volume

            property string tag: ""

            /*
            onStatusChanged: {
                if(status == SoundEffect.Ready) {
                    registerSoundReady(soundEffect)
                }
            }*/
        }
    }

    function clear() {
        App.info('SoundBank','clearing bank')
        for(var tag in bank) {
            bank[tag].destroy()
        }
        bank = {}
    }

    function registerSoundReady(object) {
        if(object.tag in bank) {
            var sound = bank[object.tag]
            if('source' in sound) {
                if(sound.source === object.source) {
                    App.info('SoundBank','Skipping',object.tag,'with sound',object.source,'it\'s already loaded')
                    object.destroy()
                    return
                } else {
                    App.info('SoundBank','Updating',object.tag,'from',sound.source,'to',object.source)
                    sound.destroy()
                }
            }
        }

        App.debug('SoundBank',soundBank,'Loaded',object.tag)
        bank[object.tag] = object
        loaded(object.tag , object)
    }

    function objectSize(obj) {
        var size = 0, key;
        for (key in obj) {
            if (key in obj) size++;
        }
        return size;
    }

    function getRandomInt(min, max) {
        return Math.floor(Math.random() * (max - min + 1) + min);
    }

    function play(tag,loops) {
        if(soundBank.muted)
            return


        // NOTE BUG iOS sound workaround
        /*
        if(Qak.platform.os === "ios") {
            core.setTimeout(function(){
                var sound
                if(tag && tag in bank) {
                    sound = bank[tag]
                    if(Utility.isInteger(loops))
                        sound.loops = loops
                    else
                        sound.loops = soundBank.loops
                    if(!sound.playing) {
                        sound.play()
                        playing(tag,sound)
                    }
                } else {
                    for(var i in bank) {
                        sound = bank[i]
                        if(!sound.playing) {
                            sound.play()
                            playing(tag,sound)
                        }
                    }
                }
            },Utility.randomRangeInt(0,200))
        } else {*/
            var sound
            if(tag && tag in bank) {
                sound = bank[tag]
                if(Utility.isInteger(loops))
                    sound.loops = loops
                else
                    sound.loops = soundBank.loops
                if(!sound.playing) {
                    sound.play()
                    playing(tag,sound)
                }
            } else {
                for(var i in bank) {
                    sound = bank[i]
                    if(!sound.playing) {
                        sound.play()
                        playing(tag,sound)
                    }
                }
            }
        //}
    }

    function playRandom() {
        if(soundBank.muted)
            return

        var keys = Object.keys( bank )
        // NOTE if index is out of bounds play() will play the whole bank
        var tag = keys[getRandomInt(0,keys.length-1)]

        //App.debug('SoundBank playRandom',tag)
        play(tag)
    }

    function mute(muted, tag) {
        if(tag && tag in bank)
            bank[tag].muted = muted
        else {
            // NOTE Don't do something stupid like this: soundBank.muted = muted
            for(var i in bank) {
                bank[i].muted = muted
            }
        }
    }

    // BUG TODO Ugly fix to let buzzer fix it's windows only sound stutter bug
    property var stop: function (tag) {
        if(tag && tag in bank)
            bank[tag].stop()
        else {
            for(var i in bank) {
                bank[i].stop()
            }
        }
    }

    function stopOther(tag) {
        for(var i in bank) {
            if(i !== tag) {
                if(bank[i].playing)
                    bank[i].stop()
            }
        }
    }


}
