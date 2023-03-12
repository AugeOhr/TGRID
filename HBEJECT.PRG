*+--------------------------------------------------------------------
*+
*+ Source Module => c:\fwh\0\LISTVIEW\HBEJECT.PRG
*+
*+    Copyright(C) 1983-2023 by Auge & Ohr
*+
*+    Functions: Procedure USBeject()
*+               Static Procedure EjectMedia()
*+
*+    Reformatted by Click! 2.05.40 on Mar-11-2023 at  8:22 am
*+
*+--------------------------------------------------------------------

#include "FIVEWIN.ch"
#include "common.ch"
#include "dll.ch"

#include "EJECTDLL.CH"

MEMVAR oFontDefault
MEMVAR oFontBig
MEMVAR BFcolor, BGcolor
MEMVAR bGradient

*+--------------------------------------------------------------------
*+
*+    Procedure USBeject()
*+
*+    Called from ( dualgrid.prg )   1 - static procedure buildmainmenu()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE USBeject( nIcoLarge, nIcoSmall )

LOCAL oDlg, oListbox, oIco
LOCAL cDrive       := SPACE( 2 )
LOCAL cTitle       := "Please, select"
LOCAL aDrives      := FillDriveArray()
LOCAL nStyle       := CBS_SIMPLE
LOCAL acItem
LOCAL acBitmaps
LOCAL acType
LOCAL bChange
LOCAL bValid
LOCAL bLDblClicked
LOCAL bWhen
LOCAL bDrawItem
LOCAL ii, iMax
LOCAL oImageList, iImage, iImage_0, aItem, nFirstUSB := 0
LOCAL oGrid, oBmp1, oButton1, oButton2
LOCAL cMsg         := ""
LOCAL lPixel       := .T.
LOCAL lDesign      := .F.
LOCAL lChkBoxes    := .F.
LOCAL lDispInfo    := .F.
LOCAL aHeader      := {}
LOCAL nOption      := 1
LOCAL bAction      := { | x | cDrive := acItem[ x ] }

   DEFAULT nIcoLarge := 256                                           // 32
   DEFAULT nIcoSmall := 32                                            // 16

   acItem := aDrives[ 1 ]
   acBitmaps := aDrives[ 2 ]
   acType := aDrives[ 3 ]
   nFirstUSB := aDrives[ 4 ]

   DEFINE WINDOW oDlg FROM 0, 0 TO 400, 450 PIXEL TITLE cTitle ICON "A1MAIN" COLOR BFcolor, BGcolor NOMINIMIZE NOMAXIMIZE

      oGrid := TGrid() :New( 0, 0,, bAction, oDlg, ;
                       BFcolor, BGcolor, lPixel, lDesign, ;
                       300, 350, cMsg, nIcoLarge, nIcoSmall, lChkBoxes, lDispInfo )

      AADD( aHeader, { "Drive", 200, 0, "C" } )
      AADD( aHeader, { "Type", 100, 0, "N" } )

      oGrid:aHeader := aHeader
      oGrid:aSource := aDrives[ 1 ]

      // paint Grid_Header
      oGrid:Use_Customdraw := .T.

      oGrid:CreateHeaderColumn()

      IF oGrid:lDispInfo = .T.
         iMax := LEN( oGrid:aSource )
         // need for LVS_OWNERDATA / ::OnDISPINFO()
         LV_SETITEMCOUNT( oGrid:hLv, iMax )
         oGrid:refreshall()
      ELSE
         iMax := LEN( aDrives[ 1 ] )
         FOR ii := 1 TO iMax
            aItem := { acItem[ ii ], STR( acType[ ii ] ) }

            oBmp1 := TBitmap() :Define( acBitmaps[ ii ],, oDlg )

            // "only" add "small"
            iImage := oGrid:oImageListSmall:Add( oBmp1 )
            // iImage_0 := MAX( 0, oGrid:oImageListBig:Add( oBmp1))

            LV_ADDITEMS( oGrid:hLv, aItem, iImage )

            DeleteObject( iImage )
            DeleteObject( oBmp1 )
         NEXT
      ENDIF

      oGrid:Setfocus()
      IF !EMPTY( nFirstUSB )
         LV_SETITEMSELECT( oGrid:hLv, nFirstUSB )
      ELSE
         MsgInfo( "no removeable Drive" )
      ENDIF

      oGrid:bClick := { | nItem | EjectMedia( cDrive ), oDlg:End() }

      @ 000, 304 BTNBMP oButton1 PROMPT "&OK" SIZE 120, 160 PIXEL OF oDlg FONT oFontDefault COLOR BFcolor, BGcolor CENTER ;         
              ACTION( EjectMedia( cDrive ), oDlg:End() )              // DEFAULT

      @ 190, 304 BTNBMP oButton2 PROMPT "&Cancel" SIZE 120, 160 PIXEL OF oDlg FONT oFontDefault COLOR BFcolor, BGcolor CENTER ;         
              ACTION( cDrive := nil, oDlg:End() )

      oButton1:bClrGrad := bGradient
      oButton2:bClrGrad := bGradient

#IFDEF __HMG__
   END WINDOW
#ENDIF

   oDlg:bKeyDown := { | nKey, nFlag | IF( nKey = VK_ESCAPE, oDlg:End(), IF( nKey = VK_RETURN, ( EjectMedia( cDrive ), oDlg:End() ), nil ) ) }
   oDlg:bResized := { | nType, nWidth, nHeight | oDlg:SetSize( 450, 400 ) }

   ACTIVATE WINDOW oDlg CENTERED

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure EjectMedia()
*+
*+    Called from ( hbeject.prg )   3 - procedure usbeject()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE EjectMedia( cDriveLetter )

LOCAL cRoot   := "RUNDLL32.EXE "
LOCAL cPath   := GETENV( "TEMP" ) + "\"
LOCAL cAction := GETENV( "SYSTEMROOT" ) + "\SYSTEM32\HOTPLUG.DLL"

   cAction += ",HotPlugSafeRemovalDriveNotification "
   cAction += VOLUMENAME( cDriveLetter + ":\" )
   cAction += " ("
   cAction += cDriveLetter + ":)"

   IF EJECTREMOVABLE( cDriveLetter )                                  // in HB_FUNC.PRG
      // MsgInfo( "The Drive " + cDriveLetter + " Can be Safely Removed", "Atenttion ! , Remove USB Ok" )

      MEMOWRIT( cPath + "ShowMsg.BAT", cRoot + cAction )
      ShellExecute( 0, "open", cPath + "ShowMsg.BAT",,, SW_HIDE )
      hb_IdleSleep( 2.0 )
      FERASE( cPath + "ShowMsg.BAT" )

   ELSE
      MsgInfo( "Failed to Safely Remove/Eject Drive " + cDriveLetter, "Atenttion ! , Failed Remove USB" )
   ENDIF
RETURN

*+ EOF: HBEJECT.PRG
