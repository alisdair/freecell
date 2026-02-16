ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
  ifeq ($(GNUSTEP_MAKEFILES),)
    $(warning )
    $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
    $(warning Perhaps gnustep-make is not properly installed,)
    $(warning so gnustep-config is not in your PATH.)
    $(warning )
    $(warning Your PATH is currently $(PATH))
    $(warning )
  endif
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_OBJCFLAGS += -include Freecell_Prefix.h -Winvalid-pch

APP_NAME = Freecell
Freecell_PRINCIPAL_CLASS=NSApplication
Freecell_APPLICATION_ICON=Freecell.tiff
Freecell_OBJC_PRECOMPILED_HEADERS=Freecell_Prefix.h
Freecell_OBJC_FILES=Card.m \
  CardView.m\
  GameController.m\
  Game.m\
  GameView.m\
  HistoryController.m\
  History.m\
  main.m\
  PreferencesController.m\
  Result.m\
  Table.m\
  TableLocation.m\
  TableMove.m
Freecell_C_FILES=vccRand.c
Freecell_RESOURCE_FILES=FreecellInfo.plist \
  Freecell.tiff\
  Licence.txt\
  Cards/bonded.png\
  Cards/large-bonded.png\
  Cards/unedited-bonded.png
Freecell_LOCALIZED_RESOURCE_FILES=Credits.html \
  InfoPlist.strings\
  Localizable.strings\
  MainMenu.nib
Freecell_LANGUAGES=Dutch English Finnish French Japanese Spanish

include $(GNUSTEP_MAKEFILES)/application.make
