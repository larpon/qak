# Qak - the QML aid kit
Qak aims to provide a set of helpful and reusable (Qt5) QML components.

Right now Qak, as a whole, are centered around components useful for 2D game making.
The master plan, however, is to break it up into smaller dedicated areas/modules.

Qak uses code from this project
https://github.com/prettymuchbryce/easystarjs

## Please note that Qak is NOT considered production ready yet
Although Qak is in use in a couple of published games (and run quite well) - it's not considered production ready.
Qak's codebase in general is stable but right now it can be used in ways that can break performance or stability - thus - not really ready for production use.

It's also poorly documented - sorry, I need more spare time :)

Currently used in these games
* [Dead Ascend](http://games.blackgrain.dk/deadascend) (Open source)
* [Hammer Bees](http://games.blackgrain.dk/hammerbees)

## Experimental CMake support
Include Qak in your CMakeLists.txt like this:
```
add_subdirectory(vendor/qak)
add_definitions( ${QAK_DEFINITIONS} )
...
qt5_add_resources( QT_RESOURCES ${QAK_RESOURCES} )
...
target_link_libraries(<bin name>
    <Propably your Qt libs here>
    ...
    qak
)
```
