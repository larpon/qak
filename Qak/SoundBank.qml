import QtQuick 2.0
import QtMultimedia 5.4

import Qak 1.0
import Qak.Tools 1.0

import "."

QakObject {
    id: soundBank

    property var bank: ({})
    property var groups: ({})

    readonly property int infinite: SoundEffect.Infinite
    property int loops: 0
    readonly property int count: internal.count

    property bool muted: false
    property real volume: 1

    property bool safePlay: true // Only play sound if it's not already playing - if false playing sound will be stopped first

    signal loaded (string tag, var sound)
    signal error (string errorMessage)

    signal playing (string tag, var sound)
    signal stopped (string tag, var sound)

    onMutedChanged: mute(muted)

    Component.onDestruction: clear()

    QtObject {
        id: internal

        property int count: 0
    }

    function add(group, tag, path, onReady) {

        var pathExists = Qak.resource.exists(path)
        if(group && tag && pathExists) {
            addGroup(group,tag,path,onReady)
            return
        }

        if(!pathExists) {
            if(Qak.resource.exists(tag)) {
                path = tag
                tag = group
            } else {
                Qak.warn(Qak.gid+'SoundBank','Seems like',path,'sound file doesn\'t exist? Not added...')
                return
            }
        }

        if(tag === '') {
            Qak.warn(Qak.gid+'SoundBank','Tag is empty for sound "'+path+'". Not added...')
            return
        }

        if(tag in bank) {
            var sound = bank[tag]
            if('source' in sound) {
                if(sound.source === path) {
//                    Qak.debug(Qak.gid+'SoundBank','Skipping',tag,'with sound',path,'it\'s already added') //¤qakdbg
                    return
                }
//                else Qak.debug(Qak.gid+'SoundBank','Updating',tag,'from',sound.source,'to',path) //¤qakdbg
            }
        }

        var attributes = {
            tag: tag,
            source: path
        }

        try {
            Incubate.now(soundEffectComponent, soundBank, attributes, function(obj){
                registerSoundReady(obj)
                if(Aid.isFunction(onReady))
                    onReady(tag,group,soundBank.get(tag,group))
            })
        } catch(e) {
            error(e)
        }

    }

    function addGroup(group, tag, path, onReady) {

        if(!Qak.resource.exists(path)) {
            Qak.warn(Qak.gid+'SoundBank','Seems like',path,'sound file doesn\'t exist? Not added...')
            return
        }

        if(group === '') {
            Qak.warn(Qak.gid+'SoundBank','Group is empty for sound "'+path+'". Not added...')
            return
        }

        if(tag === '') {
            Qak.warn(Qak.gid+'SoundBank','Tag is empty for sound "'+path+'". Not added...')
            return
        }

        if(groups[group] === undefined)
            groups[group] = {}

        if(groupExists(group) && tag in groups[group]) {
            var sound = groups[group][tag]
            if('source' in sound) {
                if(sound.source === path) {
//                    Qak.debug(Qak.gid+'SoundBank','Skipping',tag,'with sound',path,'it\'s already added') //¤qakdbg
                    return
                }
//                else Qak.debug(Qak.gid+'SoundBank','Updating',tag,'in group',group,'from',sound.source,'to',path) //¤qakdbg
            }
        }

        var attributes = {
            tag: tag,
            group: group,
            source: path
        }

        try {
            Incubate.now(soundEffectComponent, soundBank, attributes, function(obj){
                registerSoundReady(obj)
                if(Aid.isFunction(onReady))
                    onReady(tag,group,soundBank.get(tag,group))
            })
        } catch(e) {
            error(e)
        }

    }

    function get(tag,group) {
        var i, sound, sounds = []

        // Get default all of bank
        if(tag === undefined && group === undefined) {
            for(i in bank) {
                sound = bank[i]
                sounds.push(sound)
            }
            return sounds
        }

        // Get default all of group
        if(tag === undefined && group && groupExists(group)) {
            for(i in groups[group]) {
                sound = groups[group][i]
                sounds.push(sound)
            }
            return sounds
        }

        // Get tag from group specific
        if(tag && group && groupExists(group) && tag in groups[group]) {
            return groups[group][tag]
        }

        // Get tag from bank
        if(tag in bank) {
            return bank[tag]
        }

        // Get tag from group if found
        if(tag && group === undefined) {
            for(group in groups) {
                if(groups[group] && tag in groups[group]) {
                    return groups[group][tag]
                }
            }
        }

        Qak.error(Qak.gid+'SoundBank','::get','no valid combinations of arguments',tag,group)
    }

    function isGrouped(tag) {
        for(var group in groups) {
            if(groupExists(group) && tag in groups[group]) {
                if(groups[group][tag])
                    return true
            }
        }
        return false
    }

    function isGlobal(tag) {
        if(tag in bank) {
            return true
        }
        return false
    }

    function has(tag) {
        return (isGlobal(tag) || isGrouped(tag))
    }

    function groupExists(group) {
        return (!Aid.undefinedOrNull(group) && group in groups && groups[group])
    }

    function clear(group) {

        var tag

        if(group !== undefined && groupExists(group)) {
//            Qak.debug(Qak.gid+'SoundBank','::clear','clearing group',group) //¤qakdbg
            for(tag in groups[group]) {
                groups[group][tag].destroy()
            }
            groups[group] = undefined
            return
        }

        tag = group
        if(tag in bank) { // See if group matches a tag
//            Qak.debug(Qak.gid+'SoundBank','::clear','clearing tag',tag) //¤qakdbg
            bank[tag].destroy()
            bank[tag] = undefined
        }

        // If called without arguments
        if(group === undefined) {

//            Qak.debug(Qak.gid+'SoundBank','::clear','clearing bank') //¤qakdbg

            for(tag in bank) {
                bank[tag].destroy()
            }
            bank = {}

            for(group in groups) {
                for(tag in groups[group]) {
                    groups[group][tag].destroy()
                }
            }
            groups = {}
        }
    }

    function remove(group) { // Convenience function
        clear(group)
    }

    function registerSoundReady(object) {

        var sound
        if(object.group === '' && object.tag in bank) {
            sound = bank[object.tag]
            if('source' in sound) {
                if(sound.source === object.source) {
//                    Qak.debug(Qak.gid+'SoundBank','::registerSoundReady','Skipping',object.tag,'with sound',object.source,'it\'s already loaded') //¤qakdbg
                    object.destroy()
                    return
                } else {
//                    Qak.debug(Qak.gid+'SoundBank','::registerSoundReady','Updating',object.tag,'from',sound.source,'to',object.source) //¤qakdbg
                    sound.destroy()
                }
            }
        } else {
            if(groupExists(object.group) && object.tag in groups[object.group]) {
                sound = groups[object.group][object.tag]
                if('source' in sound) {
                    if(sound.source === object.source) {
//                        Qak.debug(Qak.gid+'SoundBank','::registerSoundReady','Skipping',object.tag,'in group',object.group,'with sound',object.source,'it\'s already loaded') //¤qakdbg
                        object.destroy()
                        return
                    } else {
//                        Qak.debug(Qak.gid+'SoundBank','::registerSoundReady','Updating',object.tag,'in group',object.group,'from',sound.source,'to',object.source) //¤qakdbg
                        sound.destroy()
                    }
                }
            }
        }

        var tmp
        if(object.group === '') {
            tmp = bank
            tmp[object.tag] = object
            bank = tmp
//            Qak.debug(Qak.gid+'SoundBank','::registerSoundReady',soundBank,'Loaded',object.tag) //¤qakdbg
        } else {
//            Qak.debug(Qak.gid+'SoundBank','::registerSoundReady',soundBank,'Loaded',object.tag,'in group',object.group) //¤qakdbg
            if(!groups[object.group])
                groups[object.group] = {}
            tmp = groups
            tmp[object.group][object.tag] = object
            groups = tmp
        }
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

    function play(tag,group,loops) {
        if(soundBank.muted)
            return

        if(Aid.isInteger(group) && loops === undefined) {
            loops = group
            group = undefined
        }

        var i, sound

        // Play default all of bank
        if(tag === undefined && group === undefined) {
            for(i in bank) {
                sound = bank[i]
                playSound(sound,loops)
            }
            return
        }

        // Play default all of group
        if(tag === undefined && group && groupExists(group)) {
            for(i in groups[group]) {
                sound = groups[group][i]
                playSound(sound,loops)
            }
            return
        }

        // Play tag from group specific
        if(tag && group && groupExists(group) && tag in groups[group]) {
            playSound(groups[group][tag],loops)
            return
        }

        // Play tag from bank
        if(tag in bank) {
            playSound(bank[tag],loops)
            return
        }

        // Play tag from group if found
        if(tag && group === undefined) {
            for(group in groups) {
                if(groups[group] && tag in groups[group]) {
                    playSound(groups[group][tag],loops)
                    return
                }
            }
        }

        Qak.error(Qak.gid+'SoundBank','::play','no valid combinations of arguments',tag,group,loops)

    }

    function playSound(sound,loops) {
        if(sound) {
            if(Aid.isInteger(loops))
                sound.loops = loops
            else
                sound.loops = soundBank.loops

            sound.bugFixedPlay()
            /*
            if(sound.playing) {
                sound.bugFixedStop() //.stop()
                //sound.play()
                sound.bugFixedPlay()
            } else {
                //sound.play()
                sound.bugFixedPlay()
            }*/
        }
    }

    function playRandom(group) {
        if(soundBank.muted)
            return

        var keys, tag

        if(group === undefined) {

            keys = Object.keys( bank )

            // NOTE include available groups in randomization
            var includeGroups = (Aid.objectSize(groups) > 0)
            if(includeGroups) {
                var aGroupsKeys = Object.keys( groups )
                var rGroupKey = aGroupsKeys[getRandomInt(0,aGroupsKeys.length-1)]
                if(groupExists(rGroupKey))
                    keys = keys.concat(Object.keys( groups[rGroupKey] ))
            }

            // NOTE if index is out of bounds play() will play the whole bank
            tag = keys[getRandomInt(0,keys.length-1)]

//            Qak.debug(Qak.gid+'SoundBank','::playRandom',tag) //¤qakdbg
            play(tag)
            return
        }

        if(Aid.isArray(group)) { // Expecting array of keys
            tag = group[getRandomInt(0,group.length-1)]
            play(tag)
            return
        }

        if(groupExists(group)) {
            keys = Object.keys( groups[group] )
            // NOTE if index is out of bounds play() will play the whole bank
            tag = keys[getRandomInt(0,keys.length-1)]

//            Qak.debug(Qak.gid+'SoundBank','::playRandom',tag) //¤qakdbg
            play(tag)
            return
        }
    }

    function mute(muted, tag, group) {

        var i
        if (group === undefined) {
            if(tag && tag in bank) { // Mute tag in bank
//                Qak.debug(Qak.gid+'SoundBank','::mute','muting tag',tag) //¤qakdbg
                bank[tag].muted = muted
            } else if (tag in groups) { // Mute group
//                Qak.debug(Qak.gid+'SoundBank','::mute','muting group',tag) //¤qakdbg
                for(i in groups[tag]) {
                    groups[tag][i].muted = muted
                }
            } else { // Mute whole bank
//                Qak.debug(Qak.gid+'SoundBank','::mute','muting all') //¤qakdbg
                // NOTE Don't do something stupid like this: soundBank.muted = muted (property can be binded by user)
                for(i in bank) {
                    bank[i].muted = muted
                }

                for(group in groups) {
                    if(groups[group]) {
                        for(i in groups[group]) {
                            groups[group][i].muted = muted
                        }
                    }
                }
            }
            return
        }

        if(tag && groupExists(group) && tag in groups[group]) { // Mute tag in group
//            Qak.debug(Qak.gid+'SoundBank','::mute','muting tag',tag,'in group',group) //¤qakdbg
            groups[group][tag].muted = muted
        } else if(groupExists(group)) { // Mute group
//            Qak.debug(Qak.gid+'SoundBank','::mute','muting group',group) //¤qakdbg
            for(i in groups[group]) {
                groups[group][i].muted = muted
            }
        }
    }

    // BUG TODO Ugly horrible fix to let buzzer fix it's windows only sound stutter bug
    property var stop: function (tag, group) {

        var i, gg

        // Stop everything, also the world from spinning
        if(Aid.undefinedOrNull(tag) && Aid.undefinedOrNull(group)) {
            for(i in bank) {
                if(bank[i].playing)
                    bank[i].bugFixedStop() //.stop()
            }

            for(group in groups) {
                gg = groups[group]
                if(gg) {
                    for(i in gg) {
                        if(gg[i].playing)
                            gg[i].bugFixedStop() //.stop()
                    }
                }
            }
            return
        }

        // Stop whole specific group
        if(Aid.undefinedOrNull(tag) && groupExists(group)) {
            for(i in groups[group]) {
                groups[group][i].bugFixedStop() //.stop()
            }
            return
        }

        // Stop tag from group specific
        if(!Aid.undefinedOrNull(tag) && groupExists(group) && tag in groups[group]) {
            groups[group][tag].bugFixedStop() //.stop()
            return
        }

        // Stop group
        if(!Aid.undefinedOrNull(tag) && tag in groups) {
            for(i in groups[tag]) {
                if(groups[tag][i].playing)
                    groups[tag][i].bugFixedStop() //.stop()
            }
            return
        }

        // Stop tag from bank
        if(!Aid.undefinedOrNull(tag) && tag in bank) {
            bank[tag].bugFixedStop() //.stop()
            return
        }

        // Stop tag from group if found
        if(!Aid.undefinedOrNull(tag) && group === undefined) {
            for(group in groups) {
                gg = groups[group]
                if(gg && tag in gg) {
                    gg[tag].bugFixedStop() //.stop()
                    return
                }
            }
        }

        Qak.error(Qak.gid+'SoundBank','::stop','no valid combinations of arguments',tag,group)
        /*
        var i, group

        // Stop everything, also the world from spinning
        if(!tag) {
            for(i in bank) {
                if(bank[i].playing)
                    bank[i].stop()
            }

            for(group in groups) {
                if(groups[group]) {
                    for(i in groups[group]) {
                        if(groups[group][i].playing)
                            groups[group][i].stop()
                    }
                }
            }
            return
        }

        // Stop group
        if (tag in groups) {
            for(i in groups[tag]) {
                if(groups[tag][i].playing)
                    groups[tag][i].stop()
            }
            return
        }

        // Stop tag in group
        for(group in groups) {
            if(groups[group] && tag in groups[group] && groups[group][tag].playing) {
                groups[group][tag].stop()
                return
            }
        }

        // Stop tag in bank
        if(tag && tag in bank) {
            if(bank[tag].playing)
                bank[tag].stop()
        }
        */
    }

    function stopOther(tag) {
        var i
        for(i in bank) {
            if(i !== tag) {
                if(bank[i].playing)
                    bank[i].bugFixedStop() //.stop()
            }
        }

        for(var group in groups) {
            var g = groups[group]
            for(i in g) {
                if(i !== tag) {
                    if(g[i].playing)
                        g[i].bugFixedStop() //.stop()
                }
            }
        }
    }

    Component {
        id: soundEffectComponent
        SoundEffect {
            id: soundEffect
            muted: false
            volume: soundBank.volume * mixVolume * bugFixVolume

            //category: group !== "" ? group : "SoundEffects"

            property real mixVolume: 1.0
            property real bugFixVolume: 1.0

            property string tag: ""
            property string group: ""

            onPlayingChanged: {
                if(playing)
                    soundBank.playing(tag,soundEffect)
                else
                    soundBank.stopped(tag,soundEffect)
            }

            function bugFixedPlay() {
                if(safePlay) {
                    bugFixVolume = 1.0
                }
                play()
            }

            function bugFixedStop() {
                if(safePlay) {
                    bugFixVolume = 0.0
                } else {
                    stop()
                }
            }

            /*
            onStatusChanged: {
                if(status == SoundEffect.Ready) {
                    registerSoundReady(soundEffect)
                }
            }*/
            onStatusChanged: {
                if(status == SoundEffect.Error) {
                    soundBank.error("SoundEffect error",group,tag)
                }
            }

            Component.onCompleted: internal.count++
            Component.onDestruction: internal.count--
        }
    }
}
