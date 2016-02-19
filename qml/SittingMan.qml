import QtQuick 2.2

import "qrc:///qageqml" as Qak

Qak.Entity {
    id: entity

    source: "sitting_man.png"

    SpriteSequence {
        id: sprite
        anchors.fill: parent

        onCurrentSpriteChanged: {
            //core.db("SpriteSequence",currentSprite)
        }

        Sprite {
            name: "sit"
            source: entity.adaptiveSource
            frameCount: 1
            frameWidth: 128
            frameHeight: 216
            frameDuration: 2000
            to: { "sit": 1, "sit_lookb": 1, "sit_reach": 1 }
        }

        Sprite {
            name: "sit_lookb"
            source: entity.adaptiveSource
            frameCount: 4
            frameX: 128
            frameY: 648
            frameWidth: 128
            frameHeight: 216
            frameRate: 24
            to: { "lookb": 1 }
        }

        Sprite {
            name: "sit_reach"
            source: entity.adaptiveSource
            frameCount: 4
            frameX: 128
            frameWidth: 128
            frameHeight: 216
            frameRate: 24
            to: { "reach": 1 }
        }

        Sprite {
            name: "gather"
            source: entity.adaptiveSource
            frameCount: 1
            frameX: 640
            frameY: 432
            frameWidth: 128
            frameHeight: 216
            frameDuration: 500
            to: { "gather": 1, "gather_low": 1 }
        }

        Sprite {
            name: "gather_low"
            source: entity.adaptiveSource
            frameCount: 5
            frameY: 432
            frameWidth: 128
            frameHeight: 216
            reverse: true
            frameRate: 24
            to: { "low": 1 }
        }

        Sprite {
            name: "lookb"
            source: entity.adaptiveSource
            frameCount: 1
            frameX: 640
            frameY: 648
            frameWidth: 128
            frameHeight: 216
            frameDuration: 500
            to: { "lookb": 1, "lookb_sit": 1 }
        }

        Sprite {
            name: "lookb_sit"
            source: entity.adaptiveSource
            frameCount: 4
            frameX: 128
            frameY: 648
            frameWidth: 128
            frameHeight: 216
            reverse: true
            frameRate: 24
            to: { "sit": 1 }
        }

        Sprite {
            name: "low"
            source: entity.adaptiveSource
            frameCount: 1
            frameX: 640
            frameY: 216
            frameWidth: 128
            frameHeight: 216
            frameDuration: 500
            to: { "low": 1, "low_gather": 1, "low_reach": 1 }
        }

        Sprite {
            name: "low_gather"
            source: entity.adaptiveSource
            frameCount: 5
            frameY: 432
            frameWidth: 128
            frameHeight: 216
            frameRate: 24
            to: { "gather": 1 }
        }

        Sprite {
            name: "low_reach"
            source: entity.adaptiveSource
            frameCount: 5
            frameY: 216
            frameWidth: 128
            frameHeight: 216
            reverse: true
            frameRate: 24
            to: { "reach": 1 }
        }

        Sprite {
            name: "reach"
            source: entity.adaptiveSource
            frameCount: 1
            frameX: 640
            frameWidth: 128
            frameHeight: 216
            frameDuration: 500
            to: { "reach": 1, "reach_low": 1, "reach_sit": 1 }
        }

        Sprite {
            name: "reach_low"
            source: entity.adaptiveSource
            frameCount: 5
            frameY: 216
            frameWidth: 128
            frameHeight: 216
            frameRate: 24
            to: { "low": 1 }
        }

        Sprite {
            name: "reach_sit"
            source: entity.adaptiveSource
            frameCount: 4
            frameX: 128
            frameWidth: 128
            frameHeight: 216
            reverse: true
            frameRate: 24
            to: { "sit": 1 }
        }

    }

}
