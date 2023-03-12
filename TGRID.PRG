*+--------------------------------------------------------------------
*+
*+ Source Module => c:\fwh\0\LISTVIEW\TGRID.PRG
*+
*+    Copyright(C) 1983-2023 by Auge & Ohr
*+
*+    Functions: Class TGrid
*+
*+    Reformatted by Click! 2.05.40 on Mar-11-2023 at  8:22 am
*+
*+--------------------------------------------------------------------

#include "FiveWin.ch"
#include "Constant.ch"
#include "wcolors.ch"
#include "hbthread.ch"

#include "TGRID.CH"
#include "DUALGRID.CH"

//  #define Use_NewControl                        // HB_FUNC( LV_INITLISTVIEW )

MEMVAR BFcolor, BGcolor

// ******************************* CLASS TGrid     ***************************

*+--------------------------------------------------------------------
*+
*+    Class TGrid
*+
*+--------------------------------------------------------------------
*+
CLASS TGrid FROM TControl

   CLASSDATA aProperties INIT { "nAlign", "nClrText", "nClrPane", "nOption", ;
                                "nTop", "nLeft", "nWidth", "nHeight", "Cargo" }

   DATA oParent
   DATA aItems INIT {}
   DATA aGroups INIT {}
   DATA bAction, bDisplay
   DATA bClick, bRbClick
   DATA bSideBack, bSideNext
   DATA bheaderLbDown
   DATA nOption
   DATA nGroups INIT 0

   DATA aSource INIT {}
   DATA aHeader INIT {}
   DATA oLVCol
   DATA oLVItem
   DATA aEvents INIT {}
   DATA bOnEvent
   DATA nview
   DATA hLv
   DATA oImageListBig, oImageListSmall
   DATA hFont
   DATA cPath
   DATA nIcoLarge INIT 32
   DATA nIcoSmall INIT 16
   DATA hTheme
   DATA lImage INIT .F.
   DATA lAllowed INIT .T.
   DATA cFilter INIT "*.*"
   DATA oHeader
   DATA SortOrder INIT LVS_SORTASCENDING
   DATA nColSort INIT LV_NAME
   DATA oProgress
   //    DATA lExHeader INIT .F.
   DATA aPrompts INIT {}
   DATA nGroups INIT 0
   DATA lDispInfo INIT .F.
   DATA lFileIcon INIT .F.
   DATA lCheckBox INIT .F.
   DATA aMarked INIT {}
   DATA nZerobased INIT 1
   DATA oImageLHeader
   DATA hHeader
   DATA hModule
   DATA Use_oImageLHeader INIT .F.
   DATA Use_HeaderClick INIT .F.
   DATA Use_Customdraw INIT .F.
   DATA aThread INIT {}
   DATA hThread INIT 0
   DATA lMultiThread INIT .F.                                         // ok
   DATA nLastPos INIT 0
   DATA lBreakFOR INIT .F.
   DATA lThreadActive INIT .F.
   DATA lRePosition INIT .F.
   DATA cPathMuTool INIT ""
   DATA lUse_IconEx INIT .T.

   //    DATA dwLvStyleEx
   //    DATA GridLines     IS MASK LVS_EX_GRIDLINES     OF dwLvStyleEx
   //    DATA FullRowSelect IS MASK LVS_EX_FULLROWSELECT OF dwLvStyleEx
   //    DATA DoubleBuffer  IS MASK LVS_EX_DOUBLEBUFFER  OF dwLvStyleEx
   //    DATA Checkbox      IS MASK LVS_EX_CHECKBOXES    OF dwLvStyleEx

   METHOD New( nTop, nLeft, aPrompts, bAction, oWnd, nClrFore, ;
               nClrBack, lPixel, lDesign, nWidth, nHeight, ;
               cMsg, nIcoLarge, nIcoSmall, lCheckbox, lDispInfo ) CONSTRUCTOR
   METHOD ReDefine( nId, oWnd, bAction ) CONSTRUCTOR
   METHOD DEFAULT()
   METHOD Notify( nIdCtrl, nPtrNMHDR )
   METHOD OnEvent( nEvent, aParams, pParams )
   METHOD SetImageList( oImageList, nType )
   METHOD CreateHeaderColumn()
   METHOD Destroy()
   METHOD OnDISPINFO()
   METHOD SetViewStyle()
   METHOD HandleEvent( nMsg, nWParam, nLParam )
   METHOD RefreshAll()
   METHOD RefreshCurrent( nRow )
   METHOD MarkAll()
   METHOD UnMarkAll( lAll )
   METHOD Getdata()
   METHOD RButtonDown( nRow, nCol, nKeyFlags )
   METHOD SetGridHeaderSort( nCol )
   METHOD ClearAndFillDir()

   METHOD HScroll( nWParam, nLParam ) VIRTUAL                         // required for default behavior
   METHOD VScroll( nWParam, nLParam ) VIRTUAL                         // required for default behavior

   METHOD InsertItem( nImageIndex, cText, nGroup ) INLINE LVInsertItem( ::hWnd, nImageIndex, cText, nGroup )
   METHOD InsertGroup( cText ) INLINE LVInsertGroup( ::hWnd, cText, ::nGroups ++ )
   METHOD DoMark( oWnd )
   METHOD ItemMark( nRow, nState, nMask )
   METHOD ItemUnMark( nRow, nState, nMask )
   METHOD SetTopItem( nItem )
   METHOD GetScrollbarObj( lVScroll )
   METHOD ImageThread()

   METHOD HelpTopic()

   ENDCLASS

METHOD New( nTop, nLeft, aPrompts, bAction, oWnd, nClrFore, nClrBack, lPixel, lDesign, nWidth, nHeight, cMsg, nIcoLarge, nIcoSmall, lCheckbox, lDispInfo ) CLASS TGrid

LOCAL nPosi, nExStyle

   DEFAULT nTop := 0, nLeft := 0, ;
           aPrompts := {}, ;
           oWnd := GetWndDefault(), ;
           nClrFore := oWnd:nClrText, ;
           nClrBack := GetSysColor( COLOR_BTNFACE ), ;
           lPixel := .f., ;
           lDesign := .f., ;
           lCheckbox := .f., ;
           nWidth := 200, nHeight := 21, ;
           nIcoLarge := 32, nIcoSmall := 16, ;
           lDispInfo := .F.

   LV_INITCOMMON()

   ::oParent := oWnd

   ::nview := LVS_REPORT
   ::nStyle := nOR( LVS_SHAREIMAGELISTS, WS_CHILD, WS_VISIBLE, IF( lDesign, WS_CLIPSIBLINGS, 0 ), WS_TABSTOP, WS_BORDER, LVS_SHOWSELALWAYS, LVS_AUTOARRANGE, ::nview )

   ::nId := ::GetNewId()
   ::oWnd := oWnd
   ::aPrompts := aPrompts
   ::bAction := bAction
   ::cMsg := cMsg
   ::nTop := IF( lPixel, nTop, nTop * SAY_CHARPIX_H )
   ::nLeft := IF( lPixel, nLeft, nLeft * SAY_CHARPIX_W )
   ::nBottom := ::nTop + nHeight - 1
   ::nRight := ::nLeft + nWidth - 1
   ::nWidth := nWidth
   ::lDrag := lDesign
   ::lCaptured := .f.
   ::oFont := TFont() :New( "Ms Sans Serif", 0, - 20 )
   ::nClrText := nClrFore
   ::nClrPane := nClrBack
   ::nOption := 1
   ::cPath := hb_Dirbase()

   IF lDispInfo = .T.
      ::lDispInfo := lDispInfo
      ::nStyle := nOR( ::nStyle, LVS_OWNERDATA )
      ::bDisplay := { | nPtrNMHDR | ::OnDISPINFO( nPtrNMHDR ) }
      ::bLClicked := { | n | IF( GetKeyState( VK_CONTROL ), ::DoMark( ::oWnd ), nil ) }
   ENDIF

   IF !EMPTY( oWnd:hWnd )
#ifdef Use_NewControl
      ::hWnd := LV_InitListView( oWnd:hWnd, 0, nLeft, nTop, nWidth, nHeight, lDispInfo, 100, .T., .F., .T., .T. )
      ::Link()
#else
      ::Create( CTRL_CLASS )
#ENDIF
      oWnd:AddControl( Self )
   ELSE
      oWnd:DefControl( Self )
   ENDIF

   // ::Default()                                                     // what is this ?

   IF lDesign                                                         // what is this ?
      // ::CheckDots()
   ENDIF

   // handle of Listview
   ::hLv := ::hWnd

   // set FONT
   ::hFont := ::oFont:hFont
   SendMessage( ::hLv, WM_SETFONT, ::hFont, 0 )

   LV_SETBKCOLOR( ::hLv, nRGBRED( nClrBack ), nRGBGREEN( nClrBack ), nRGBBLUE( nClrBack ) )
   LV_SETTEXTBKCOLOR( ::hLv, nRGBRED( nClrBack ), nRGBGREEN( nClrBack ), nRGBBLUE( nClrBack ) )
   LV_SETTEXTCOLOR( ::hLv, nRGBRED( nClrFore ), nRGBGREEN( nClrFore ), nRGBBLUE( nClrFore ) )

   // set FULLROWSELECT
   nExStyle := nOr( LVS_EX_FULLROWSELECT, LVS_EX_DOUBLEBUFFER )
   IF lCheckbox = .T.
      ::lCheckbox := .T.
      nExStyle := nOr( nExStyle, LVS_EX_CHECKBOXES )
   ENDIF
   // nExStyle := nOr( nExStyle, LVS_EX_GRIDLINES)
   LV_CHANGEEXTENDEDSTYLE( ::hLv, nExStyle )

   IF IsAppThemed()
      ::hTheme := C5_OpenThemeData( ::hLv, "LISTVIEW" + CHR( 0 ) )
   ENDIF

   // Icon Size
   ::nIcoLarge := nIcoLarge
   ::nIcoSmall := nIcoSmall

   ::oImageListBig := TImageList() :New( ::nIcoLarge, ::nIcoLarge )
   ::oImageListSmall := TImageList() :New( ::nIcoSmall, ::nIcoSmall )

   ::SetImageList( ::oImageListBig, LVSIL_NORMAL )
   ::SetImageList( ::oImageListSmall, LVSIL_SMALL )

   ::lMultiThread := hb_mtvm()

   //    ondummy( "TGrid Start", TIME() )
RETURN Self

METHOD ReDefine( nId, oWnd, bAction ) CLASS TGrid                     // unknown

   DEFAULT oWnd := GetWndDefault()

   ::nId := nId
   ::oWnd := oWnd
   ::bAction := bAction
   ::aPrompts := {}

   oWnd:DefControl( Self )

RETURN Self

METHOD DEFAULT() CLASS TGrid

LOCAL n

   //    FOR n = 1 TO LEN( ::aPrompts )
   //       ::InsertItem( n - 1, ::aPrompts[ n ], 0 )
   //    NEXT

RETURN ::Super:Default()

METHOD Destroy() CLASS TGrid

   IF !EMPTY( ::oImageListBig )
      ::oImageListBig:End()                                           // ILDESTROY ?
   ENDIF
   IF !EMPTY( ::oImageListSmall )
      ::oImageListSmall:End()
   ENDIF
   IF !EMPTY( ::oImageLHeader )
      ::oImageLHeader:End()
   ENDIF

   IF ::hTheme != 0
      C5_CloseThemeData( ::hTheme )
   ENDIF
   ::oParent := nil

   ::Super:End()

RETURN Self

METHOD CreateHeaderColumn() CLASS TGrid

LOCAL WinDir     := GETENV( "Windir" )
LOCAL nCol, nMax
LOCAL nWidth, cCaption, nFMT, iImage := - 1
LOCAL nClrFore   := ::nClrText
LOCAL nClrBack   := ::nClrPane
LOCAL aColSizes  := {}
LOCAL aBitmaps   := {}
LOCAL hImageList, iIcon, cDLL, hDC

   IF ::Use_HeaderClick
      ::bheaderLbDown := { | nPtrNMHDR, nCol, nItem | ::SetGridHeaderSort( nCol, nItem, .T. ) }
   ENDIF

   IF ::Use_oImageLHeader
      ::oImageLHeader := TImageList() :New( 16, 16 )
   ENDIF

   cDLL := WinDir + "\System32\NetShell.dll"

   FOR nCol := 1 TO LEN( ::aHeader )
      cCaption := ::aHeader[ nCol ] [ ID_HEADER ] + CHR( 0 )
      nWidth   := ::aHeader[ nCol ] [ ID_WIDTH ]
      nFMT     := ::aHeader[ nCol ] [ ID_ALIGN ]

      IF ::Use_oImageLHeader
         IF ::lUse_IconEx = .T.
            ::hModule := GetModuleHandle( cDLL )
            IF ::hModule == 0
               ::hModule := LoadLibrary( cDLL )
            ENDIF
            iIcon  := LOADIMAGERESICON( ::hModule, 2301, 16 )
            iImage := ILAddIcon( ::oImageLHeader:hImageList, iIcon )

         ELSE
            iImage := ::oImageLHeader:AddIcon( "ICOUP" )
         ENDIF

      ENDIF

      LV_INSERTCOLUMN( ::hLv, nCol, nWidth, cCaption, nFMT, iImage )

      IF ::Use_oImageLHeader
         IF ::lUse_IconEx = .T.
         DestroyIcon( iIcon )
         ENDIF
         DestroyIcon( iImage )
      ENDIF

   NEXT

   ::hHeader := LV_GETHEADER( ::hLv )

   IF ::Use_oImageLHeader
      SendMessage( ::hHeader, HDM_SETIMAGELIST, 0, ::oImageLHeader:hImageList )
   ENDIF

   IF ::Use_Customdraw
      IF BGColor = 256 * 256 * 256 - 1                                // 16777215
         //  Msginfo("white")
      ELSE
         SetWindowTheme( ::hHeader, "", "" )
      ENDIF
   ENDIF

   IF ::lDispInfo = .T.
      nMax := LEN( ::aSource )
      // need for LVS_OWNERDATA / ::OnDISPINFO()
      LV_SETITEMCOUNT( ::hLv, nMax )
   ENDIF

RETURN self

METHOD Notify( nIdCtrl, nPtrNMHDR ) CLASS TGrid

LOCAL nCode := GetNMHDRCode( nPtrNMHDR )
LOCAL nItem := GETNMHEAITEM( nPtrNMHDR )
LOCAL nKey
LOCAL nPosi, nRow, r

STATIC nOption

   DO CASE

      CASE nCode == LVN_GETDISPINFO
         IF ::bDisplay != nil
            EVAL( ::bDisplay, nPtrNMHDR, Self )
         ENDIF

      CASE nCode == NM_DBLCLK
         nOption := GetNMListViewItem( nPtrNMHDR ) + 1
         IF ::bClick != nil
            ::nOption := nOption
            //             IF ::lAllowed = .T.
            EVAL( ::bClick, ::nOption, Self )
            //             ENDIF
         ENDIF

      CASE nCode == NM_CLICK
         nOption = GetNMListViewItem( nPtrNMHDR ) + 1
         IF ::nOption != nOption
            ::nOption := nOption
         ENDIF

      CASE nCode == LVN_ITEMCHANGED
         nOption := GetNMListViewItem( nPtrNMHDR ) + 1
         IF ::nOption != nOption
            ::nOption := nOption
            IF ::bAction != nil
               EVAL( ::bAction, ::nOption, Self )
            ENDIF
         ENDIF

      CASE nCode == LVN_KEYDOWN
         nKey := LV_GETGRIDVKEY( nPtrNMHDR )
         IF nKey = 13
            IF ::bClick != nil
               //                IF ::lAllowed = .T.
               //  nOption := GetNMListViewItem( nPtrNMHDR ) + 1
               //  ::nOption := nOption
               //  use last from LVN_ITEMCHANGED
               EVAL( ::bClick, ::nOption, Self )
               //                ENDIF
            ENDIF

         ELSEIF nKey = 32
            nRow := ::nOption

            nPosi := ASCAN( ::aMarked, { | x | x = nRow } )
            IF nPosi > 0
               ::ItemUnMark( nRow )
            ELSE
               ::ItemMark( nRow )
            ENDIF
            ::RefreshCurrent( nRow )
         ENDIF

      CASE nCode == LVN_COLUMNCLICK
         IF ::Use_HeaderClick
            nOption := GetNMListViewItem( nPtrNMHDR ) + 1
            nKey := LV_GETGRIDCOLUMN( nPtrNMHDR )
            IF ::bheaderLbDown != nil
               //                IF ::lAllowed = .T.
               EVAL( ::bheaderLbDown, nPtrNMHDR, nKey + 1, nItem )
               //                ENDIF
            ENDIF
         ENDIF

      CASE nCode == NM_CUSTOMDRAW

         IF ::Use_Customdraw
            r := HEADER_CUSTOMDRAW_GetAction( nPtrNMHDR )
            IF r <> - 1
               RETURN r                                               // return CDRF_NOTIFYITEMDRAW or CDRF_DODEFAULT
            ENDIF
            // Set the color of the Listview header
            RETURN HEADER_SETCOLOR( nPtrNMHDR, BGCOLOR, BFCOLOR )
         ENDIF

   ENDCASE

RETURN nil

METHOD OnDISPINFO( nPtrNMHDR ) CLASS TGrid

LOCAL nPosi
LOCAL aItem
LOCAL nRow
LOCAL nSub
LOCAL ctext
LOCAL cFile
LOCAL iImage
LOCAL bSaveError, oError

   bSaveError := ERRORBLOCK()
   ERRORBLOCK( { | e | BREAK( e ) } )
   BEGIN SEQUENCE

      aItem := LV_GETGRIDDISPINFOINDEX( nPtrNMHDR )
      nRow := aItem[ 1 ]
      nSub := aItem[ 2 ]
      ctext := ::aSource[ nRow ] [ nSub ]                             // + CHR( 0 )

      DO CASE
         CASE VALTYPE( cText ) = "C"
            cText := TRIM( cText )
         CASE VALTYPE( cText ) = "N"
            cText := TRANSFORM( cText, "999,999,999,999" )
         CASE VALTYPE( cText ) = "D"
            cText := DTOC( cText )
         CASE VALTYPE( cText ) = "L"
            cText := IF( cText, "Y", "N" )
      ENDCASE

      LV_SETGRIDQUERYDATA( nPtrNMHDR, ctext, LEN( ctext ) )

      IF ::lFileIcon = .T.
         IF nSub == 1
            cFile := ::cPath + ctext
            iImage := Icon_Read( cFile )
            ILADDICON( ::oImageListSmall:hImageList, iImage )
            iImage := MAX( 0, ILADDICON( ::oImageListBig:hImageList, iImage ) )
            LV_SETGRIDQUERYIMAGE( nPtrNMHDR, iImage )
            DeleteObject( iImage )
         ENDIF
      ENDIF

      IF ::lCheckBox = .T.
         IF nSub == 1
            nPosi := ASCAN( ::aMarked, { | x | x = nRow } )
            IF nPosi > 0 .OR. LV_GETCHECKSTATE( ::hLv, nRow )
               LV_SETCHECKITEM( nPtrNMHDR, 2 )
            ELSE
               LV_SETCHECKITEM( nPtrNMHDR, 1 )
            ENDIF
         ENDIF
      ENDIF

   END SEQUENCE
   ERRORBLOCK( bSaveError )

RETURN 0

METHOD OnEvent( nEvent, aParams, pParams ) CLASS TGrid                // unused

LOCAL nAt    := ASCAN( ::aEvents, { | aEvent | aEvent[ 2 ] == nEvent } )
LOCAL cEvent := IF( nAt != 0, ::aEvents[ nAt ] [ 1 ], "" )

   IF !EMPTY( ::bOnEvent )
      EVAL( ::bOnEvent, IF( !EMPTY( cEvent ), cEvent, nEvent ), aParams, pParams )
   ENDIF

RETURN nil

METHOD SetImageList( oImageList, nType ) CLASS TGrid

LOCAL nResult

   DEFAULT nType := LVSIL_NORMAL

   nResult = SendMessage( ::hLv, LVM_SETIMAGELIST, nType, oImageList:hImageList )

   SysRefresh()

RETURN nResult

METHOD SetViewStyle( nView ) CLASS TGrid

   DEFAULT nView := LVS_REPORT

   DO CASE
      CASE nView = LVS_ICON
         ::nStyle := nOR( LVS_SHAREIMAGELISTS, WS_CHILD, WS_VISIBLE, WS_TABSTOP, WS_BORDER, LVS_SHOWSELALWAYS, LVS_AUTOARRANGE, LVS_ICON )
      CASE nView = LVS_SMALLICON
         ::nStyle := nOR( LVS_SHAREIMAGELISTS, WS_CHILD, WS_VISIBLE, WS_TABSTOP, WS_BORDER, LVS_SHOWSELALWAYS, LVS_AUTOARRANGE, LVS_SMALLICON )
      CASE nView = LVS_LIST
         ::nStyle := nOR( LVS_SHAREIMAGELISTS, WS_CHILD, WS_VISIBLE, WS_TABSTOP, WS_BORDER, LVS_SHOWSELALWAYS, LVS_AUTOARRANGE, LVS_LIST )
      CASE nView = LVS_REPORT
         ::nStyle := nOR( LVS_SHAREIMAGELISTS, WS_CHILD, WS_VISIBLE, WS_TABSTOP, WS_BORDER, LVS_SHOWSELALWAYS, LVS_AUTOARRANGE, LVS_REPORT )
   ENDCASE
   IF ::lDispInfo = .T.
      ::nStyle := nOR( ::nStyle, LVS_OWNERDATA )
   ENDIF

   SetWindowLong( ::hLv, GWL_STYLE, ::nStyle )
   ::nview := nView

   IF ::lCheckBox = .T.
      LV_ChangeExtendedStyle( ::hLv, LVS_EX_CHECKBOXES )
   ELSE
      LV_ChangeExtendedStyle( ::hLv,, LVS_EX_CHECKBOXES )
   ENDIF

   REDRAWWINDOW( ::hLv )
   UpdateWindow( ::hLv )

RETURN nView

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TGrid              // unused

   DO CASE
         //  use for LVS_OWNERDRAWFIXED
      CASE nMsg == WM_MEASUREITEM
      CASE nMsg == WM_DRAWITEM

      CASE nMsg == WM_XBUTTONDOWN
         IF NLOWORD( nWParam ) = MK_XBUTTON1
            IF !EMPTY( ::bSideBack )
               EVAL( ::bSideBack )
            ENDIF
         ELSEIF NLOWORD( nWParam ) = MK_XBUTTON2
            IF !EMPTY( ::bSideNext )
               EVAL( ::bSideNext )
            ENDIF
         ENDIF

      CASE nMsg == WM_SYSCOMMAND
         RETURN nil

   ENDCASE

RETURN ::Super:HandleEvent( nMsg, nWParam, nLParam )

METHOD RefreshAll() CLASS TGrid

LOCAL nCount := LV_GetCountPerPage( ::hLv )
LOCAL nTopNo := LV_GetTopIndex( ::hLv )
LOCAL nRow

   // IF ::lCheckBox = .T.
   FOR nRow := nTopNo TO nTopNo + nCount
      LV_UPDATE( ::hLv, nRow )
   NEXT
   // ENDIF
   LV_RedrawItems( ::hLv, nTopNo, nTopNo + nCount )
   LV_ENSUREVISIBLE( ::hLv, nTopNo )
RETURN self

METHOD RefreshCurrent( nRow ) CLASS TGrid

   LV_UPDATE( ::hLv, nRow )
   LV_RedrawItems( ::hLv, nRow, nRow )
   LV_ENSUREVISIBLE( ::hLv, nRow )

RETURN self

METHOD UnMarkAll() CLASS TGrid

LOCAL nRow, cName, nPosi, nFirstVisible := 0
LOCAL nCurrentTopIndex := lv_GetTopIndex( ::hLv )
LOCAL iMax             := LV_GETSELECTEDCOUNT( ::hLv )
LOCAL nCount           := 0
LOCAL nState           := hb_BitOr( LVIS_SELECTED, LVIS_FOCUSED )
LOCAL nMask            := hb_BitOr( LVIS_SELECTED, LVIS_FOCUSED )
LOCAL aDir             := My_Directory( EndwithSlash( ::cPath ) + ::cFilter )

   LOCKWINDOWUPDATE( ::hLv )

   nRow := LV_GetSelectionMark( ::hLv )
   LV_SETITEMSTATE( ::hLv, nRow, 0, nOr( LVIS_SELECTED, LVIS_FOCUSED ) )
   nFirstVisible := nRow

   iMax := LV_GETSELECTEDCOUNT( ::hLv )
   IF iMax > 0
      nRow := LV_GETNEXTITEM( ::hLv, - 1 )
      LV_SETITEMSTATE( ::hLv, nRow, 0, nOr( LVIS_SELECTED, LVIS_FOCUSED ) )
      IF !EMPTY( nRow ) .AND. nRow > nFirstVisible
         nFirstVisible := nRow
      ENDIF

      DO WHILE .T.
         nRow := LV_GETNEXTITEM( ::hLv, nRow )
         nCount ++
         IF nRow > 0
            LV_SETITEMSTATE( ::hLv, nRow, 0, nOr( LVIS_SELECTED, LVIS_FOCUSED ) )
            LV_SETCHECKSTATE( ::hLv, nRow, .F. )

            IF nRow > nFirstVisible
               nFirstVisible := nRow
            ENDIF
         ELSE
            EXIT
         ENDIF
         IF nCount > iMax
            EXIT
         ENDIF
      ENDDO
   ENDIF

   iMax := LEN( ::aSource )
   FOR nRow := 1 TO iMax
      nPosi := ASCAN( ::aMarked, { | x | x = nRow } )
      IF nPosi > 0
         ADEL( ::aMarked, nPosi )
         ASIZE( ::aMarked, LEN( ::aMarked ) - 1 )
         LV_SETCHECKSTATE( ::hLv, nRow, .F. )
      ENDIF
   NEXT
   LOCKWINDOWUPDATE( 0 )

   IF ::lCheckBox = .T.
      ::RefreshAll()
   ENDIF

   ::ItemMark( MAX( nCurrentTopIndex + 1, nFirstVisible ) )

RETURN self

METHOD MarkAll() CLASS TGrid

LOCAL nRow   := 1
LOCAL iMax   := LEN( ::aSource )                                      // LV_GETITEMCOUNT()
LOCAL nState := nOr( LVIS_FOCUSED, LVIS_SELECTED )
LOCAL nMask  := nOr( LVIS_SELECTED, LVIS_FOCUSED )
LOCAL aDir   := My_Directory( EndwithSlash( ::cPath ) + ::cFilter )
LOCAL cAttr, cName, cExt, cFile, nPosi, nFirstVisible := 0

   LV_SETITEMSTATE( ::hLv, nRow, 0, nOr( LVIS_SELECTED, LVIS_FOCUSED ) )

   LOCKWINDOWUPDATE( ::hLv )
   //  ( zero-based )
   FOR nRow := 1 TO iMax

      cAttr := ::aSource[ nRow ] [ LV_ATTR ]
      cName := UPPER( TRIM( ::aSource[ nRow ] [ LV_NAME ] ) )
      //      cExt  := TRIM(::aSource[ nRow ] [ LV_EXT  ] )

      DO CASE
         CASE "S" $ cAttr
         CASE "D" $ cAttr
         CASE cName == ".."
         CASE cName == "."
         OTHERWISE
            IF ASCAN( aDir, { | x | UPPER( x[ LV_NAME ] ) = cName } ) > 0
               LV_SETITEMSTATE( ::hLv, nRow, nState, nOr( LVIS_SELECTED, LVIS_FOCUSED ) )

               nPosi := ASCAN( ::aMarked, { | x | x = nRow } )
               IF nPosi = 0
                  AADD( ::aMarked, nRow )
                  LV_SETCHECKSTATE( ::hLv, nRow, .T. )
               ENDIF

               IF EMPTY( nFirstVisible )
                  nFirstVisible := nRow
               ENDIF
            ENDIF
      ENDCASE
   NEXT
   LOCKWINDOWUPDATE( 0 )

   IF ::lCheckBox = .T.
      ::RefreshAll()
   ENDIF

   ::SetTopItem( nFirstVisible )

RETURN NIL

METHOD Getdata() CLASS TGrid

LOCAL aRet   := {}
LOCAL nRow   := - 1
LOCAL nCount := 0
LOCAL iMax
LOCAL nPosi
LOCAL nState

   iMax := LV_GETSELECTEDCOUNT( ::hLv )

   IF iMax > 0
      nRow := LV_GETNEXTITEM( ::hLv, - 1 )
      AADD( aRet, nRow )
      DO WHILE .T.
         nRow := LV_GETNEXTITEM( ::hLv, nRow )
         nCount ++
         IF nRow > 0
            AADD( aRet, nRow )
         ELSE
            EXIT
         ENDIF
         IF nCount > iMax
            EXIT
         ENDIF
      ENDDO

      //    ELSE
      //       AADD(aRet, ::lv_GetSelectionMark() )
   ENDIF

   IF ::lCheckBox = .T.
      iMax := LEN( ::aSource )
      FOR nRow := 1 TO iMax
         nState := LV_GetCheckState( ::hLv, nRow )
         IF nState = .T.
            IF ASCAN( aRet, { | x | x = nRow } ) > 0
            ELSE
               AADD( aRet, nRow )
            ENDIF
         ENDIF
      NEXT
   ENDIF

   nPosi := 1
   DO WHILE !EMPTY( nPosi )
      nPosi := ASCAN( aRet, { | x | x = 0 } )
      IF nPosi > 0
         ADEL( aRet, nPosi )
         ASIZE( aRet, LEN( aRet ) - 1 )
      ENDIF
   ENDDO
RETURN aRet

METHOD RButtonDown( nRow, nCol, nKeyFlags ) CLASS TGrid

   IF ::bRbClick != nil
      EVAL( ::bRbClick, ::oWnd, nRow, nCol, nKeyFlags )
   ENDIF
RETURN Self

METHOD SetGridHeaderSort( nCol, nItem, lChange ) CLASS TGrid

LOCAL WinDir   := GETENV( "Windir" )
LOCAL cDLL     := WinDir + "\System32\NetShell.dll"
LOCAL aDirOut  := ACLONE( ::aSource )
LOCAL aCol     := ACLONE( ::aHeader )
LOCAL hGrid    := ::hLv
LOCAL nStartAt := 1
LOCAL ii, nMax
LOCAL nWidth, cCaption, nAlign, iImage, iIcon, hBitmap

   DEFAULT lChange := .T.

   IF nCol = - 1
      IF ::Use_oImageLHeader
         ImageList_RemoveAll( ::oImageLHeader:hImageList )

         nMax := LEN( aCol )
         ii := 1
         FOR ii := 1 TO nMax
            IF ::lUse_IconEx = .T.
               LV_SETSORTHEADERDLL( hGrid, ii, 0 )
            ELSE
               LV_SetSortHeaderICO( hGrid, ii, 0 )
            ENDIF
         NEXT
      ENDIF

   ELSE

      IF lChange = .T.
         IF ::SortOrder = LVS_SORTASCENDING
            ::SortOrder := LVS_SORTDESCENDING
         ELSE
            ::SortOrder := LVS_SORTASCENDING
         ENDIF
      ENDIF

      ::nColSort := nCol

      IF ::Use_oImageLHeader
         ImageList_RemoveAll( ::oImageLHeader:hImageList )

         nMax := LEN( aCol )
         ii := 1
         FOR ii := 1 TO nMax
            IF ::SortOrder = LVS_SORTASCENDING
         IF ::lUse_IconEx = .T.
               iIcon := LOADIMAGERESICON( ::hModule, 2301, 16 )
               iImage := ILAddIcon( ::oImageLHeader:hImageList, iIcon )
         ELSE
               iImage := ::oImageLHeader:AddIcon( "ICOUP" )
         ENDIF
            ELSE
         IF ::lUse_IconEx = .T.
               iIcon := LOADIMAGERESICON( ::hModule, 2300, 16 )
               iImage := ILAddIcon( ::oImageLHeader:hImageList, iIcon )
         ELSE
               iImage := ::oImageLHeader:AddIcon( "ICODOWN" )
         ENDIF
            ENDIF

         IF ::lUse_IconEx = .T.
            LV_SETSORTHEADERDLL( hGrid, ii, 0 )
         ELSE
            LV_SetSortHeaderICO( hGrid, ii, 0 )
         ENDIF

         IF ::lUse_IconEx = .T.
            DestroyIcon( iIcon )
         ENDIF
            DestroyIcon( iImage )
         NEXT

      ENDIF

      IF ::SortOrder = LVS_SORTASCENDING
         IF ::lUse_IconEx = .T.
            iIcon := LOADIMAGERESICON( ::hModule, 2301, 16 )
            LV_SETSORTHEADERDLL( hGrid, nCol, 1, iIcon )
            DestroyIcon( iIcon )
         ELSE
            LV_SetSortHeaderICO( hGrid, nCol, 1 )
         ENDIF
      ELSE
         IF ::lUse_IconEx = .T.
            iIcon := LOADIMAGERESICON( ::hModule, 2300, 16 )
            LV_SETSORTHEADERDLL( hGrid, nCol, - 1, iIcon )
            DestroyIcon( iIcon )
         ELSE
            LV_SetSortHeaderICO( hGrid, nCol, - 1 )
         ENDIF
      ENDIF

      //    IF nCol = LV_DATE .OR. nCol = LV_TIME
      //       nStartAt := 0
      //    ELSE
      // "D"irectry on Top
      ASORT( aDirOut,,, { | x, y | "D" $ x[ LV_ATTR ] } )
      AEVAL( aDirOut, { | x, i | nStartAt := IF( "D" $ x[ LV_ATTR ], i, nStartAt ) } )
      ASORT( aDirOut, 1, nStartAt, { | x, y | LOWER( x[ LV_NAME ] ) < LOWER( y[ LV_NAME ] ) } )
      //    ENDIF

      cCaption := ::aHeader[ nCol ] [ ID_HEADER ] + CHR( 0 )
      nWidth := ::aHeader[ nCol ] [ ID_WIDTH ]
      nAlign := ::aHeader[ nCol ] [ ID_ALIGN ]

      DO CASE
         CASE nCol = LV_NAME
            IF ::SortOrder = LVS_SORTASCENDING
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( UPPER( x[ LV_NAME ] ), UPPER( y[ LV_NAME ] ), .T. ) } )
               // ASORT( aDirOut, nStartAt + 1,, { | x, y | CompareFile( x[ LV_NAME ], y[ LV_NAME ], .T. ) } )
            ELSE
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( UPPER( x[ LV_NAME ] ), UPPER( y[ LV_NAME ] ), .F. ) } )
               // ASORT( aDirOut, nStartAt + 1,, { | x, y | CompareFile( x[ LV_NAME ], y[ LV_NAME ], .F. ) } )
            ENDIF

         CASE nCol = LV_SIZE
            IF ::SortOrder = LVS_SORTASCENDING
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( x[ LV_SIZE ] ) < ( y[ LV_SIZE ] ) } )
            ELSE
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( x[ LV_SIZE ] ) > ( y[ LV_SIZE ] ) } )
            ENDIF

         CASE nCol = LV_DATE
            IF ::SortOrder = LVS_SORTASCENDING
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( x[ LV_DATE ] ) < ( y[ LV_DATE ] ) } )
            ELSE
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( x[ LV_DATE ] ) > ( y[ LV_DATE ] ) } )
            ENDIF

         CASE nCol = LV_TIME
            IF ::SortOrder = LVS_SORTASCENDING
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( x[ LV_TIME ] ) < ( y[ LV_TIME ] ) } )
            ELSE
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( x[ LV_TIME ] ) > ( y[ LV_TIME ] ) } )
            ENDIF

         CASE nCol = LV_ATTR
            IF ::SortOrder = LVS_SORTASCENDING
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( x[ LV_ATTR ] ) < ( y[ LV_ATTR ] ) } )
            ELSE
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( x[ LV_ATTR ] ) > ( y[ LV_ATTR ] ) } )
            ENDIF

         CASE nCol = LV_EXT
            IF ::SortOrder = LVS_SORTASCENDING
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( x[ LV_EXT ] + UPPER( x[ LV_NAME ] ) ) < ( y[ LV_EXT ] + UPPER( y[ LV_NAME ] ) ) } )
            ELSE
               ASORT( aDirOut, nStartAt + 1,, { | x, y | ( x[ LV_EXT ] + UPPER( x[ LV_NAME ] ) ) > ( y[ LV_EXT ] + UPPER( y[ LV_NAME ] ) ) } )
            ENDIF

      ENDCASE

   ENDIF

   ::aSource := ACLONE( aDirOut )

   IF ::lDispInfo = .T.
      nMax := LEN( ::aSource )
      // need for LVS_OWNERDATA / ::OnDISPINFO()
      LV_SETITEMCOUNT( ::hLv, nMax )
      ::refreshall()
   ELSE
      IF lChange = .T.

         ::ClearAndFillDir()

      ENDIF
   ENDIF

RETURN aDirOut

METHOD ClearAndFillDir( oDlg ) CLASS TGrid

LOCAL nRow, nMax, aItem, iImage, iTemp_0, iTemp_1, cIcoOrBmp := ""
LOCAL cFile, aBitmaps, cExt, nError, nPosi, lErase := .F.
LOCAL cParameter, cPNG, nEvery
LOCAL nPerPage   := LV_GetCountPerPage( ::hLv )
LOCAL hVScroll   := 0
LOCAL oParent, oSelf := SELF
LOCAL bMethod
LOCAL bSaveError, oError

   IF !EMPTY( oDlg )
      oParent := oDlg
   ELSE
      oParent := ::oParent
   ENDIF

   bSaveError := ERRORBLOCK()
   ERRORBLOCK( { | e | BREAK( e ) } )
   BEGIN SEQUENCE

      IF ::lAllowed = .T.
         ::lAllowed := .F.                                            // disable Notify
         ::lBreakFOR := .F.

         SendMessage( ::hLv, LVM_DELETEALLITEMS, 0, 0 )
         ImageList_RemoveAll( ::oImageListSmall:hImageList )
         ImageList_RemoveAll( ::oImageListBig:hImageList )
         SysRefresh()

         ::oProgress := TProgress() :New( 4, 0, oParent, 0,,, .T., .F., oParent:nWidth - 1, 8 )
         ::oProgress:SetRange( 0, 100 )
         ::oProgress:SetPos( 0 )
         ::oProgress:SetStep( 1 )

         nMax := LEN( ::aSource )
         nEvery := ROUND( nMax / 100, 0 )
         nEvery := MAX( 1, nEvery )

         nRow := 1

         IF nMax > nPerPage
            // hVScroll := ::GetScrollbarObj()
         ENDIF

         IF ::lMultiThread = .T. .AND. ::lDispInfo = .F.
            // using Function
            // ::hThread := hb_threadDetach( hb_threadStart( HB_BITOR( HB_THREAD_INHERIT_PUBLIC, HB_THREAD_MEMVARS_COPY ), @ImageThread_XX(), oSelf ) )

            // using Codeblock
            bMethod := { || ::ImageThread() }
            ::hThread := hb_threadDetach( hb_threadStart( HB_BITOR( HB_THREAD_INHERIT_PUBLIC, HB_THREAD_MEMVARS_COPY ), @bMethod ) )
            AADD( ::aThread, ::hThread )
         ENDIF

         // add Item
         FOR nRow := 1 TO nMax
            IF ::lBreakFOR = .T.
               EXIT
            ENDIF

            cIcoOrBmp := ""

            IF !EMPTY( nEvery )
               IF ( nRow % nEvery ) = 0
                  ::oProgress:StepIt()
                  SysRefresh()
               ENDIF
            ENDIF

            aItem := { ::aSource[ nRow ] [ LV_NAME ], ;
                       TRIM( ::aSource[ nRow ] [ LV_EXT ] ), ;
                       STR( ::aSource[ nRow ] [ LV_SIZE ] ), ;
                       DTOC( ::aSource[ nRow ] [ LV_DATE ] ), ;
                       ::aSource[ nRow ] [ LV_TIME ], ;
                       TRIM( ::aSource[ nRow ] [ LV_ATTR ] ) }

            cFile := TRIM( ::aSource[ nRow ] [ LV_NAME ] )

            // slow down a lot ...
            // SayBar( cFile )

            SysRefresh()

            IF ::lMultiThread = .F.
               IF ::lImage = .T.

                  cParameter := ""
                  lErase := .F.
                  cExt := UPPER( cFileExt( cFile ) )

                  IF cExt $ "PDF" .AND. .NOT. EMPTY( ::cPathMuTool )
                     cPNG := STRTRAN( UPPER( cFile ), ".PDF", ".PNG" )
                     //  mutool draw -o "%1.png" -r 96 -h 150 "%1" 1-1
                     cParameter := "draw -o " + ::cPath + cPNG + " -r 96 -h 192 " + ::cPath + cFile + " 1-1"

                     nError := WaitRun( "mutool.exe " + cParameter, SW_HIDE )

                     IF nError = 0
                        cExt := "PNG"
                        cFile := cPNG
                        SysRefresh()
                        lErase := .T.
                     ELSE
                        lErase := .F.
                     ENDIF
                  ENDIF

                  IF cExt $ "BMP,JPG,PNG,GIF,ICO,CUR,DLL,JPEG,TIF,TIFF,EMF,WMF"
                     cIcoOrBmp := "BMP"

                     // ******** small Icon ********
                     // make it +8 Pixel bigger while RESIZEBMP() do NOT change Aspect Ratio

                     aBitmaps := ::oWnd:ReadImage( ::cPath + cFile, { ::nIcoSmall + 8, ::nIcoSmall + 8 } )
                     iTemp_0 := aBitmaps[ 1 ]

                     // change Aspect Ratio while else might not display
                     iTemp_1 := RESIZEBMP( iTemp_0, ::nIcoSmall, ::nIcoSmall, .T. )

                     ILADD( ::oImageListSmall:hImageList, iTemp_1 )

                     PalBmpFree( aBitmaps )
                     // Delete Object
                     DeleteObject( iTemp_0 )
                     DeleteObject( iTemp_1 )
                     SysRefresh()

                     // ******** big Icon **********

                     aBitmaps := ::oWnd:ReadImage( ::cPath + cFile, { ::nIcoLarge + ::nIcoSmall, ::nIcoLarge + ::nIcoSmall } )
                     iTemp_0 := aBitmaps[ 1 ]

                     // change Aspect Ratio while else might not display
                     iTemp_1 := RESIZEBMP( iTemp_0, ::nIcoLarge, ::nIcoLarge, .T. )

                     iImage := MAX( 0, ILADD( ::oImageListBig:hImageList, iTemp_1 ) )

                     PalBmpFree( aBitmaps )
                     // Delete Object
                     DeleteObject( iTemp_0 )
                     DeleteObject( iTemp_1 )
                     SysRefresh()
                  ELSE
                     cIcoOrBmp := "ICO"

                     // search for System Icon
                     iTemp_0 := Icon_Read( ::cPath + cFile, 32 )
                     ILADDICON( ::oImageListSmall:hImageList, iTemp_0 )
                     iImage := MAX( 0, ILADDICON( ::oImageListBig:hImageList, iTemp_0 ) )
                     DestroyIcon( iTemp_0 )
                     SysRefresh()
                  ENDIF
               ELSE
                  cIcoOrBmp := "ICO"

                  // search for System Icon
                  iTemp_0 := Icon_Read( ::cPath + cFile, 32 )
                  ILADDICON( ::oImageListSmall:hImageList, iTemp_0 )
                  iImage := MAX( 0, ILADDICON( ::oImageListBig:hImageList, iTemp_0 ) )
                  DestroyIcon( iTemp_0 )
                  SysRefresh()
               ENDIF

               LV_ADDITEMS( ::hLv, aItem, iImage )

               // Delete iImage
               DO CASE
                  CASE cIcoOrBmp = "BMP"
                     DeleteObject( iImage )
                  CASE cIcoOrBmp = "ICO"
                     DestroyIcon( iImage )
               ENDCASE
               SysRefresh()

               IF !EMPTY( cParameter ) .AND. lErase = .T.
                  FERASE( ::cPath + cFile )
               ENDIF

            ELSE
               LV_ADDITEMS( ::hLv, aItem, nRow )
            ENDIF
         NEXT

         ::oProgress:End()
         ::oProgress := NIL

         ::RefreshAll()
         IF !EMPTY( ::nLastPos )
            LV_SETITEMSELECT( ::hLv, ::nLastPos )
         ELSE
            LV_SETITEMSELECT( ::hLv, 1 )
         ENDIF

         ::lAllowed := .T.                                            // enable Notify
      ENDIF

   RECOVER
      ERRORBLOCK( bSaveError )
      ::lAllowed := .T.                                               // enable Notify
   END SEQUENCE
   ERRORBLOCK( bSaveError )

RETURN nil

METHOD DoMark( oWnd ) CLASS TGrid

LOCAL nPosi
LOCAL aHit
LOCAL nState  := hb_BitOr( LVIS_SELECTED, LVIS_FOCUSED )
LOCAL nMask   := hb_BitOr( LVIS_SELECTED, LVIS_FOCUSED )
LOCAL nRow    := 1
LOCAL nCol    := 1
LOCAL aPoint
LOCAL lSelect

   oWnd:CoorsUpdate()
   aPoint := GetCursorPos( { @nRow, @nCol } )
   ScreenToClient( ::hLv, aPoint )
   nRow := aPoint[ 1 ]
   nCol := aPoint[ 2 ]

   aHit := LV_HITTEST( ::hLv, nRow, nCol )
   // zero based and 1st (".") missing
   nRow := aHit[ 1 ]

   IF nRow < 0

   ELSE
      IF LV_GETITEMSTATE( ::hLv, nRow, LVIS_SELECTED ) = LVIS_SELECTED
         LV_SETITEMSTATE( ::hLv, nRow, 0, nOr( LVIS_SELECTED, LVIS_FOCUSED ) )
         LV_SETCHECKSTATE( ::hLv, nRow, .F. )

         lSelect := .F.
      ELSE
         LV_SETITEMSTATE( ::hLv, nRow, nState, nOr( LVIS_SELECTED, LVIS_FOCUSED ) )
         LV_SETCHECKSTATE( ::hLv, nRow, .T. )
         lSelect := .T.
      ENDIF

      ::RefreshCurrent( nRow )
   ENDIF

RETURN self

METHOD ItemMark( nRow, nState, nMask ) CLASS TGrid

LOCAL nPosi

   DEFAULT nState := hb_BitOr( LVIS_SELECTED, LVIS_FOCUSED )
   DEFAULT nMask := hb_BitOr( LVIS_SELECTED, LVIS_FOCUSED )

   nPosi := ASCAN( ::aMarked, { | x | x = nRow } )
   IF nPosi = 0
      AADD( ::aMarked, nRow )
   ENDIF

   LV_SETITEMSTATE( ::hLv, nRow, nState, nMask )
   LV_SETCHECKSTATE( ::hLv, nRow, .T. )

   LV_EnsureVisible( ::hLv, nRow, .T. )
RETURN self

METHOD ItemUnMark( nRow, nState, nMask ) CLASS TGrid

LOCAL nPosi

   DEFAULT nState := hb_BitOr( 0, LVIS_FOCUSED )
   DEFAULT nMask := hb_BitOr( LVIS_SELECTED, LVIS_FOCUSED )

   nPosi := ASCAN( ::aMarked, { | x | x = nRow } )
   IF nPosi > 0
      ADEL( ::aMarked, nPosi )
      ASIZE( ::aMarked, LEN( ::aMarked ) - 1 )
   ENDIF

   LV_SETITEMSTATE( ::hLv, nRow, hb_BitOr( 0, LVIS_FOCUSED ), nMask )
   LV_SETCHECKSTATE( ::hLv, nRow, .F. )

   LV_EnsureVisible( ::hLv, nRow, .T. )
RETURN self

METHOD SetTopItem( nItem ) CLASS TGrid

LOCAL nCurrentTopIndex := lv_GetTopIndex( ::hLv )
LOCAL nItemsPerPage    := lv_GetCountPerPage( ::hLv )
LOCAL nMaxItem         := LEN( ::aSource )
LOCAL hGrid            := ::hLv

   DEFAULT nItem := 0

   IF nCurrentTopIndex > nItem
      LV_EnsureVisible( hGrid, nItem, .T. )

   ELSEIF ( nItem - nCurrentTopIndex ) >= nItemsPerPage

      IF ( nItem + nItemsPerPage ) > nMaxItem
         LV_EnsureVisible( hGrid, nMaxItem, .T. )
      ELSE
         LV_EnsureVisible( hGrid, ( nItem + nItemsPerPage ) - 1, .T. )
      ENDIF

   ENDIF

   // ListView_SetTopIndex = ListView_GetTopIndex(lv.hwnd) + 1

RETURN NIL

METHOD GetScrollbarObj( oSelf, lVScroll ) CLASS TGrid

LOCAL oObj, cTitle := ""
LOCAL hWnd := 0

   DEFAULT oSelf := SELF
   DEFAULT lVScroll := .T.

   IF lVScroll
      cTitle := "oVScroll"
      IF __objHasData( oSelf, "oVScroll" )
         oObj := oSelf:oVScroll                                       // VERTICAL
      ELSE
         Msginfo( "no Data oVScroll", cTitle )
      ENDIF
   ELSE
      cTitle := "oHScroll"
      IF __objHasData( oSelf, "oHScroll" )
         oObj := oSelf:oHScroll                                       // HORIZONTAL
      ELSE
         Msginfo( "no Data oHScroll", cTitle )
      ENDIF
   ENDIF

#ifdef Check_Method
   IF lVScroll
      IF __objHasMethod( oSelf, "oVScroll" )
         oObj := oSelf:oVScroll                                       // VERTICAL
      ELSE
         Msginfo( "no Method oVScroll", cTitle )
      ENDIF
   ELSE
      IF __objHasMethod( oSelf, "oHScroll" )
         oObj := oSelf:oHScroll                                       // VERTICAL
      ELSE
         Msginfo( "no Method oHScroll", cTitle )
      ENDIF
   ENDIF
#endif

   IF VALTYPE( oObj ) = "O"
      IF __objHasData( oObj, "hWnd" )
         hWnd := oObj:hWnd
      ELSE
         Msginfo( "no oObj:hWnd", cTitle )
      ENDIF
   ELSE
      Msginfo( "Object " + hb_valToExp( oObj ), cTitle )
   ENDIF

RETURN hWnd

METHOD ImageThread() CLASS TGrid

LOCAL nMax, iImage, iTemp_0, iTemp_1, cIcoOrBmp := ""
LOCAL cFile, aBitmaps, cExt, nError, nPosi, lErase := .F.
LOCAL cParameter, cPNG, cType
LOCAL nPerPage, ii
LOCAL hVScroll   := 0
LOCAL oParent
LOCAL bSaveError, oError

   ::lRePosition := .T.
   ::lThreadActive := .T.

   bSaveError := ERRORBLOCK()
   ERRORBLOCK( { | e | BREAK( e ) } )
   BEGIN SEQUENCE

      nPerPage := LV_GetCountPerPage( ::hLv )

      nMax := LEN( ::aSource )
      FOR ii := 1 TO nMax

         cFile := TRIM( ::aSource[ ii ] [ LV_NAME ] )
         cType := ::aSource[ ii ] [ LV_ATTR ]

         IF ::lImage = .T.

            cParameter := ""
            lErase := .F.
            cExt := UPPER( cFileExt( cFile ) )

            IF cExt $ "PDF" .AND. .NOT. EMPTY( ::cPathMuTool )
               cPNG := STRTRAN( UPPER( cFile ), ".PDF", ".PNG" )
               //  mutool draw -o "%1.png" -r 96 -h 150 "%1" 1-1
               cParameter := "draw -o " + ::cPath + cPNG + " -r 96 -h 192 " + ::cPath + cFile + " 1-1"

               nError := WaitRun( "mutool.exe " + cParameter, SW_HIDE )

               IF nError = 0
                  cExt := "PNG"
                  cFile := cPNG
                  SysRefresh()
                  lErase := .T.
               ELSE
                  lErase := .F.
               ENDIF
            ENDIF

            IF cExt $ "BMP,JPG,PNG,GIF,ICO,CUR,DLL,JPEG,TIF,TIFF,EMF,WMF"
               cIcoOrBmp := "BMP"

               // ******** small Icon ********
               // make it +8 Pixel bigger while RESIZEBMP() do NOT change Aspect Ratio

               aBitmaps := ::oWnd:ReadImage( ::cPath + cFile, { ::nIcoSmall + 8, ::nIcoSmall + 8 } )
               iTemp_0 := aBitmaps[ 1 ]

               // change Aspect Ratio while else might not display
               iTemp_1 := RESIZEBMP( iTemp_0, ::nIcoSmall, ::nIcoSmall, .T. )

               ILADD( ::oImageListSmall:hImageList, iTemp_1 )

               PalBmpFree( aBitmaps )
               // Delete Object
               DeleteObject( iTemp_0 )
               DeleteObject( iTemp_1 )
               SysRefresh()

               // ******** big Icon **********

               aBitmaps := ::oWnd:ReadImage( ::cPath + cFile, { ::nIcoLarge + ::nIcoSmall, ::nIcoLarge + ::nIcoSmall } )
               iTemp_0 := aBitmaps[ 1 ]

               // change Aspect Ratio while else might not display
               iTemp_1 := RESIZEBMP( iTemp_0, ::nIcoLarge, ::nIcoLarge, .T. )

               iImage := MAX( 0, ILADD( ::oImageListBig:hImageList, iTemp_1 ) )

               PalBmpFree( aBitmaps )
               // Delete Object
               DeleteObject( iTemp_0 )
               DeleteObject( iTemp_1 )
               SysRefresh()
            ELSE
               cIcoOrBmp := "ICO"

               // search for System Icon
               iTemp_0 := Icon_Read( ::cPath + cFile, 32 )
               ILADDICON( ::oImageListSmall:hImageList, iTemp_0 )
               iImage := MAX( 0, ILADDICON( ::oImageListBig:hImageList, iTemp_0 ) )
               DestroyIcon( iTemp_0 )
               SysRefresh()
            ENDIF
         ELSE
            cIcoOrBmp := "ICO"

            // search for System Icon
            iTemp_0 := Icon_Read( ::cPath + cFile, 32 )
            ILADDICON( ::oImageListSmall:hImageList, iTemp_0 )
            iImage := MAX( 0, ILADDICON( ::oImageListBig:hImageList, iTemp_0 ) )
            DestroyIcon( iTemp_0 )
            SysRefresh()
         ENDIF

         // zero-based
         LV_SetItemImageIndex( ::hLv, ii - 1, 0, iImage )
         LV_UPDATE( ::hLv, ii - 1 )
         LV_UPDATE( ::hLv, ii )

         IF !EMPTY( cParameter ) .AND. lErase = .T.
            FERASE( ::cPath + cFile )
         ENDIF

      NEXT

      ::RefreshAll()

      IF ::lRePosition
         IF !EMPTY( ::nLastPos )
            LV_SETITEMSELECT( ::hLv, ::nLastPos )
         ELSE
            LV_SETITEMSELECT( ::hLv, 1 )
         ENDIF
      ENDIF

   END SEQUENCE
   ERRORBLOCK( bSaveError )
   ::lThreadActive := .F.

   // hb_threadDetach( LEN( ::aThread ) )               // close thread handle
   // hb_threadQuitRequest( LEN( ::aThread ) )          // terminate thread
   ::aThread[ LEN( ::aThread ) ] := NIL
   ADEL( ::aThread, LEN( ::aThread ) )
   ASIZE( ::aThread, LEN( ::aThread ) - 1 )
   ::hThread := LEN( ::aThread )

RETURN nil

METHOD HelpTopic() CLASS TGrid

LOCAL cText := ""

   cText += "F1   this Help" + CRLF
   cText += "F2   System Folder" + CRLF
   cText += "F3   " + CRLF
   cText += "F4   Viewer (DBF)" + CRLF
   cText += "F5   copy File(s)" + CRLF
   cText += "F6   move File(s)" + CRLF
   cText += "F7   create Folder" + CRLF
   cText += "F8   delete File(s)" + CRLF
   cText += "F9   History" + CRLF
   cText += "F10  Context Menu (need click)" + CRLF
   cText += "F11  Windows Function" + CRLF
   cText += "F12  " + CRLF
   cText += "" + CRLF
   cText += "CTRL + F3  sort Name" + CRLF
   cText += "CTRL + F4  sort Extension" + CRLF
   cText += "CTRL + F5  sort Size" + CRLF
   cText += "CTRL + F6  sort Date" + CRLF
   cText += "CTRL + F7  unsort" + CRLF
   cText += "" + CRLF
   cText += "CTRL + T   new TAB" + CRLF
   cText += "" + CRLF
   cText += "ALT + F1   Combobox left Side" + CRLF
   cText += "ALT + F2   Combobox right Side" + CRLF
   cText += "" + CRLF
   cText += "ALT + F7   Search for File " + CRLF
   cText += "" + CRLF
   cText += "NUM Pad +  Select" + CRLF
   cText += "NUM Pad -  DeSelect" + CRLF
   cText += "" + CRLF

   Msginfo( cText )

RETURN 0                                                              // WM_HELP is not passed to its parent

//
//
//

*+ EOF: TGRID.PRG