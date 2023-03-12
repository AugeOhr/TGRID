/*********************************************************************

ListView_GetItemCount               https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getitemcount
ListView_InsertItem                 https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_insertitem
ListView_SetItemText                https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_setitemtext
ListView_InsertColumn               https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_insertcolumn
ListView_GetExtendedListViewStyle   https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getextendedlistviewstyle
ListView_SetExtendedListViewStyle   https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_setextendedlistviewstyle
ListView_DeleteColumn               https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_deletecolumn
ListView_EnsureVisible              https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_ensurevisible
ListView_GetBkColor                 https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_setbkcolor
ListView_GetCountPerPage            https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getcountperpage
ListView_GetItemState               https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getitemstate
ListView_GetItem                    https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getitem
ListView_GetNextItem                https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getnextitem
ListView_GetSelectedCount           https://learn.microsoft.com/de-de/windows/win32/api/commctrl/nf-commctrl-listview_getselectedcount
ListView_GetSelectionMark           https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getselectionmark
ListView_GetTextColor               https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_gettextcolor
ListView_GetTopIndex                https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_gettopindex
ListView_GetSubItemRect             https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getsubitemrect
ListView_GetItemRect                https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getitemrect
ListView_SubItemHitTest             https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_subitemhittest
ListView_RedrawItems                https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_redrawitems
ListView_Scroll                     https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_scroll
ListView_SetBkColor                 https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_setbkcolor
ListView_SetItemCount               https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_setitemcount
ListView_SetItemState               https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_setitemstate
ListView_SetTextBkColor             https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_settextbkcolor
ListView_SetTextColor               https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_settextcolor
ListView_Update                     https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_update
ListView_GetHeader                  https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getheader
ListView_SetColumnWidth             https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_setcolumnwidth
ListView_GetColumnWidth             https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_setcolumnwidth
ListView_SetCheckState              https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_setcheckstate
ListView_GetCheckState              https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-listview_getcheckstate
*********************************************************************/

******************************** HB_FUNC()      ****************************

#pragma BEGINDUMP

#include <windows.h>
#include <commctrl.h>
#include <dbt.h>
#include <hbapi.h>
#include <hbapiitm.h>
#include "hbapifs.h"
#include <ShlObj.h>
#include <tchar.h>

#include <winioctl.h>
#include <stdio.h>

#define AVOID_COMPILER_WARNING   // by Dr. Claudio Soto (November 2013)

#define LVIS_UNCHECKED 0x1000
#define LVIS_CHECKED   0x2000

static void ShowNotifyInfo(HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText, LPSTR szInfo, LPSTR szInfoTitle);

// #define UNICODE
LPWSTR AnsiToWide( LPSTR cAnsi );

// Prototypes
BOOL EjectVolume(TCHAR cDriveLetter);
HANDLE OpenVolume(TCHAR cDriveLetter);
BOOL LockVolume(HANDLE hVolume);
BOOL DismountVolume(HANDLE hVolume);
BOOL PreventRemovalOfVolume(HANDLE hVolume , BOOL fPrevent);
BOOL AutoEjectVolume(HANDLE hVolume);
BOOL CloseVolume(HANDLE hVolume);

LPTSTR szVolumeFormat = TEXT("\\\\.\\%c:");
LPTSTR szRootFormat = TEXT("%c:\\");

HANDLE OpenVolume(TCHAR cDriveLetter)
{
   HANDLE hVolume;
   UINT uDriveType;
   TCHAR szVolumeName[8];
   TCHAR szRootName[5];
   DWORD dwAccessFlags;

   wsprintf(szRootName, szRootFormat, cDriveLetter);
   uDriveType = GetDriveType(szRootName);

   switch(uDriveType)
   {
   case DRIVE_REMOVABLE:
     dwAccessFlags = GENERIC_READ | GENERIC_WRITE;
     break;
   case DRIVE_CDROM:
     dwAccessFlags = GENERIC_READ;
     break;
   default:
     return INVALID_HANDLE_VALUE;
   }

   wsprintf(szVolumeName, szVolumeFormat, cDriveLetter);

   hVolume = CreateFile( szVolumeName,
                         dwAccessFlags,
                         FILE_SHARE_READ | FILE_SHARE_WRITE,
                         NULL,
                         OPEN_EXISTING,
                         0,
                         NULL );
   return hVolume;
}

BOOL CloseVolume(HANDLE hVolume)
{
   return CloseHandle(hVolume);
}

#define LOCK_TIMEOUT        10000       // 10 Seconds
#define LOCK_RETRIES        20

BOOL LockVolume( HANDLE hVolume )
{
   DWORD dwBytesReturned;
   DWORD dwSleepAmount;
   int nTryCount;

   dwSleepAmount = LOCK_TIMEOUT / LOCK_RETRIES;

   for( nTryCount = 0; nTryCount < LOCK_RETRIES; nTryCount++ )
   {
     if( DeviceIoControl( hVolume, FSCTL_LOCK_VOLUME, NULL, 0, NULL, 0,
                          &dwBytesReturned, NULL ) )
         return TRUE;

     Sleep( dwSleepAmount );
   }

   return FALSE;
}

BOOL DismountVolume( HANDLE hVolume )
{
   DWORD dwBytesReturned;
   return DeviceIoControl( hVolume, FSCTL_DISMOUNT_VOLUME, NULL, 0, NULL, 0,
                           &dwBytesReturned, NULL );
}

BOOL AutoEjectVolume( HANDLE hVolume )
{
   DWORD dwBytesReturned;
   return DeviceIoControl( hVolume, IOCTL_STORAGE_EJECT_MEDIA, NULL, 0, NULL, 0,
                         &dwBytesReturned,
                         NULL );
}

BOOL EjectVolume( TCHAR cDriveLetter )
{
   HANDLE hVolume;
   BOOL bResult = FALSE;

   hVolume = OpenVolume(cDriveLetter);
     if( hVolume != INVALID_HANDLE_VALUE )
   {
      bResult = LockVolume( hVolume );
      if( bResult )
      {
         bResult = DismountVolume( hVolume );
         if( bResult )
         {
            bResult = PreventRemovalOfVolume( hVolume, FALSE );
            if( bResult )
            {
               bResult = AutoEjectVolume( hVolume );
               if( bResult )
               {
                  CloseVolume( hVolume );
               }
            }
         }
      }
   }
   return  bResult ;
}


typedef struct _PREVENT_MEDIA_REMOVALX {
  BOOL PreventMediaRemoval;
} PREVENT_MEDIA_REMOVALX, *PPREVENT_MEDIA_REMOVALX;

BOOL PreventRemovalOfVolume(HANDLE hVolume, BOOL fPrevent )
{
   DWORD dwBytesReturned;
   PREVENT_MEDIA_REMOVALX PMRBuffer;

   PMRBuffer.PreventMediaRemoval = (BOOL) fPrevent ;
   return DeviceIoControl( hVolume, IOCTL_STORAGE_MEDIA_REMOVAL,
                           &PMRBuffer, sizeof(PREVENT_MEDIA_REMOVALX),
                           NULL, 0, &dwBytesReturned, NULL );
}

HB_FUNC( EJECTREMOVABLE )
{
   hb_retl( EjectVolume( ( TCHAR ) * hb_parc( 1 ) ) );
   return;
}


HB_FUNC( C_GETSPECIALFOLDER ) // Contributed By Ryszard Ryüko
{
   TCHAR *lpBuffer = (TCHAR*) hb_xgrab( (MAX_PATH+1) * sizeof(TCHAR));
   LPITEMIDLIST pidlBrowse;    // PIDL selected by user
   SHGetSpecialFolderLocation(GetActiveWindow(), hb_parni(1) , &pidlBrowse) ;
   SHGetPathFromIDList(pidlBrowse,lpBuffer);
   hb_retc(lpBuffer);
   hb_xfree( lpBuffer);
}

HB_FUNC( SHFILE )
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif

   SHFILEOPSTRUCT sh;

   memset( ( char * ) &sh, 0, sizeof( sh ) );

   sh.hwnd   = hWnd ;
   sh.wFunc  = ( UINT ) hb_parnl( 2 );
   sh.pFrom  = ( LPSTR ) hb_parc( 3 );
   sh.pTo    = ( LPSTR ) hb_parc( 4 );
   sh.fFlags = ( FILEOP_FLAGS ) hb_parnl( 5 );
   sh.hNameMappings = 0;
   sh.lpszProgressTitle = NULL;

   hb_retnl( SHFileOperation( &sh ) );
}

HB_FUNC( SHOWFILEPROPERTIES )
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif

   SHELLEXECUTEINFO SHExecInfo;
   ZeroMemory(&SHExecInfo, sizeof(SHExecInfo));

   SHExecInfo.cbSize       = sizeof(SHExecInfo);
   SHExecInfo.fMask        = SEE_MASK_INVOKEIDLIST;
   SHExecInfo.lpVerb       = "Properties";
   SHExecInfo.lpDirectory  = hb_parc(2);
   SHExecInfo.lpFile       = hb_parc(3);
   SHExecInfo.nShow        = SW_SHOW;
   SHExecInfo.hwnd         = hWnd;

   ShellExecuteEx(&SHExecInfo);
}

HB_FUNC( GETKEYBOARDLAYOUT )
{
   DWORD idThread = (DWORD) hb_parni (1);   // Zero for the current thread
   HKL hkl = GetKeyboardLayout (idThread);
   hb_retnll( ( LONG_PTR ) hkl );
}

HB_FUNC( FINDWINDOWEX )
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
      HWND hWnd2 = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
      HWND hWnd2 = ( HWND ) hb_parnll( 1 );
   #endif


   hb_retnll( ( LONG_PTR )  FindWindowEx ( hWnd ,
                                           hWnd2,
                                           hb_parc  (3),
                                           hb_parc  (4)  ));
}

HB_FUNC( REDRAWWINDOW )
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   RedrawWindow (hWnd, NULL , NULL , RDW_ERASE | RDW_FRAME | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
}

//********************************************************************************************************
// Shell_NotifyIcon
//********************************************************************************************************

HB_FUNC( SHOWNOTIFYINFO )
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif

   HICON hIcon;
   if ( HB_ISNUM( 3 ) )
   {
      hIcon = LoadIcon( ( HINSTANCE ) GetModuleHandle (NULL), MAKEINTRESOURCE( hb_parni( 3 ) ) );
   }
   else
   {
      hIcon = ( HICON ) LoadImage( ( HINSTANCE ) NULL, hb_parc( 3 ), IMAGE_ICON, 0, 0, LR_LOADFROMFILE );
   }

   ShowNotifyInfo( (HWND) hWnd, (BOOL) hb_parl(2), hIcon , (LPSTR) hb_parc(4), (LPSTR) hb_parc(5), (LPSTR) hb_parc(6) );
}

static void ShowNotifyInfo(HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText, LPSTR szInfo, LPSTR szInfoTitle)
{
    NOTIFYICONDATA nid;

    ZeroMemory( &nid, sizeof(nid) );

    nid.cbSize       = sizeof(NOTIFYICONDATA);
    nid.hIcon        = hIcon;
    nid.hWnd         = hWnd;
    nid.uID          = 0;
    nid.uFlags       = NIF_INFO | NIF_TIP | NIF_ICON ;
    nid.dwInfoFlags  = NIIF_INFO ;

    lstrcpy( nid.szTip, TEXT(szText) );
    lstrcpy( nid.szInfo, TEXT(szInfo) );
    lstrcpy( nid.szInfoTitle, TEXT(szInfoTitle) );

    if(bAdd)
        Shell_NotifyIcon( NIM_ADD, &nid );
    else
        Shell_NotifyIcon( NIM_DELETE, &nid );

    if(hIcon)
        DestroyIcon( hIcon );
}

//********************************************************************************************************
// Listview API Function
//********************************************************************************************************

HB_FUNC( IMAGELIST_REMOVEALL )                   // ok
{
   #ifndef _WIN64
   ImageList_RemoveAll( ( HIMAGELIST ) hb_parnl( 1 ) );
   #else
   ImageList_RemoveAll( ( HIMAGELIST ) hb_parnll( 1 ) );
   #endif
}

// LV_ADDITEM ( hWnd, aItem, [nRow] )
HB_FUNC( LV_ADDITEM )                            // ok
{
   LV_ITEM lvi;
   WORD nColumnCount;
   int nCol, nRow;

   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   nColumnCount = ( WORD ) hb_parinfa (2, 0);

   if ( HB_ISNIL(4) )
      nRow = ListView_GetItemCount (hWnd);
   else
      nRow = hb_parni (3);

   lvi.mask       = LVIF_TEXT | LVIF_DI_SETITEM ;
   lvi.state      = 0;
   lvi.stateMask  = 0;
   lvi.iImage     = -1;
   lvi.iSubItem   = 0;
   lvi.iItem      = nRow;
   lvi.pszText    = (TCHAR*) hb_parvc (2, 1);

   ListView_InsertItem (hWnd, &lvi);

   for (nCol = 1; nCol < nColumnCount; nCol++)
       ListView_SetItemText (hWnd, nRow, nCol, (TCHAR*) hb_parvc (2, nCol+1));

}

// LV_ADDITEMS ( hWnd, aItem, iImage, [nRow] )
HB_FUNC( LV_ADDITEMS )                           // ok
{
   LV_ITEM lvi;
   WORD nColumnCount;
   int nCol, nRow;

   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   nColumnCount = ( WORD ) hb_parinfa (2, 0);

   if ( HB_ISNIL(4) )
      nRow = ListView_GetItemCount (hWnd);
   else
      nRow = hb_parni (4);

   lvi.mask       = LVIF_TEXT | LVIF_IMAGE | LVIF_DI_SETITEM ;
   lvi.state      = 0;
   lvi.stateMask  = 0;
   lvi.iImage     = hb_parni (3);
   lvi.iSubItem   = 0;
   lvi.iItem      = nRow;
   lvi.pszText    = (TCHAR*) hb_parvc (2, 1);

   ListView_InsertItem (hWnd, &lvi);

   for (nCol = 1; nCol < nColumnCount; nCol++)
       ListView_SetItemText (hWnd, nRow, nCol, (TCHAR*) hb_parvc (2, nCol+1));

}

// LV_ADDCOLUMN( hWnd, nSubItem, nWeight, cText, nFMT )
HB_FUNC( LV_ADDCOLUMN )                          // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   LV_COLUMN COL;

   COL.mask= LVCF_WIDTH | LVCF_TEXT | LVCF_FMT | LVCF_SUBITEM ;
   COL.cx= hb_parni(3);
   COL.pszText = (TCHAR*) hb_parc(4);
   COL.iSubItem=hb_parni(2)-1;
   COL.fmt = hb_parni(5) ;

   ListView_InsertColumn ( hWnd, hb_parni(2)-1, &COL );
}

// LV_ChangeExtendedStyle ( hWnd, [ nAddStyle ], [ nRemoveStyle ] )
HB_FUNC( LV_CHANGEEXTENDEDSTYLE )                // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   DWORD Add     = (DWORD) hb_parnl  (2);
   DWORD Remove  = (DWORD) hb_parnl  (3);
   DWORD OldStyle, NewStyle, Style;

   OldStyle = ListView_GetExtendedListViewStyle (hWnd);
   NewStyle = (OldStyle | Add) & ( ~Remove );
   Style = ListView_SetExtendedListViewStyle ( hWnd, NewStyle );
   hb_retnl ((LONG) Style);
}

HB_FUNC( LV_COLUMNEND )
{
   hb_xfree( ( void * ) hb_parptr( 1 ) );
}

HB_FUNC( LV_DELETECOLUMN )                       // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   ListView_DeleteColumn ( hWnd, hb_parni(2)-1 );
}

// LV_ENSUREVISIBLE( hWnd, nItem, lPart)
HB_FUNC( LV_ENSUREVISIBLE)                       // ok
{
   BOOL lEnablePartialView = HB_ISLOG (3) ? hb_parl (3) : TRUE;
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   ListView_EnsureVisible( hWnd, hb_parni(2)-1 , lEnablePartialView ) ;
}

HB_FUNC( LV_GETBKCOLOR )                         // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retnl ( ListView_GetBkColor ( hWnd ) ) ;
}

// LV_GETCHECKSTATE (hWnd, nRow)
HB_FUNC( LV_GETCHECKSTATE)
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   UINT nRow   = (UINT) hb_parnl (2);
   hb_retl ( ListView_GetCheckState(hWnd, nRow-1) );
}

HB_FUNC( LV_GETCOUNTPERPAGE )                    // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retnl ( ListView_GetCountPerPage ( hWnd ) ) ;
}

// LV_GETCOLUMNWIDTH(hWnd, nCol)                 // nCol = Zero-based
HB_FUNC( LV_GETCOLUMNWIDTH )                     // ok
{
   #ifndef _WIN64
      HWND hGrid = ( HWND ) hb_parnl( 1 );
   #else
      HWND hGrid = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retni ( ListView_GetColumnWidth ( hGrid, hb_parni(2) ) ) ;
}


HB_FUNC( LV_GETITEMSTATE )                       // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   INT  nRow   = (INT)  hb_parni  (2);
   UINT uMask  = (UINT) hb_parni  (3);

   hb_retni ((INT) ListView_GetItemState ( hWnd, (nRow - 1), uMask ) );
}

// LV_GETITEMTEXT (ControlHandle, nRow, nCol)
HB_FUNC( LV_GETITEMTEXT )                        // ok
{
   TCHAR buffer [1024] ;
   LV_ITEM lvi;

   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif

   lvi.mask = LVIF_TEXT | LVIF_IMAGE | LVIF_DI_SETITEM ;
   lvi.state = 0;
   lvi.stateMask = 0;
   lvi.iItem = hb_parni( 2 ) - 1;
   lvi.iSubItem = hb_parni( 3 ) - 1; ;
   lvi.cchTextMax = 1022;
   lvi.pszText = buffer;
   buffer[ 0 ] = 0;
   buffer[ 1023 ] = 0;

   ListView_GetItem( hWnd, &lvi );

   hb_retc (lvi.pszText);
}

// LV_GETITEMCOUNT(hWnd)
HB_FUNC( LV_GETITEMCOUNT )                       // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retnl ( ListView_GetItemCount ( hWnd ) ) ;
}

// LV_GETGRIDDISPINFOINDEX(nPtrNMHDR)
HB_FUNC( LV_GETGRIDDISPINFOINDEX )               // ok
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif

   LV_DISPINFO * pDispInfo = ( LV_DISPINFO * ) lParam;
   int iItem = pDispInfo->item.iItem;
   int iSubItem = pDispInfo->item.iSubItem;

   hb_reta( 2 );
   hb_storvni( iItem    + 1, -1, 1 );
   hb_storvni( iSubItem + 1, -1, 2 );
}


// LV_GETGRIDVKEY( nPtrNMHDR )
HB_FUNC( LV_GETGRIDVKEY )                        // ok
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   LV_KEYDOWN * LVK = (LV_KEYDOWN*) lParam;
   hb_retni ( LVK->wVKey );
}

HB_FUNC( LV_GETGRIDCOLUMN )                      // ok
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif

   NM_LISTVIEW * NMLV = (NM_LISTVIEW*) lParam;

   hb_retni ( NMLV->iSubItem );
}

// LV_GETHEADER( hWnd )
HB_FUNC( LV_GETHEADER )                          // ok
{
   #ifndef _WIN64
      HWND hGrid = ( HWND ) hb_parnl( 1 );
   #else
      HWND hGrid = ( HWND ) hb_parnll( 1 );
   #endif

   hb_retnll( ( LONG_PTR ) ListView_GetHeader( hGrid ) );
}

HB_FUNC( LV_GETHEADERLISTVIEWITEM )              // ok
{
   #ifndef _WIN64
      LPNMHEADER lpnmheader = ( LPNMHEADER ) hb_parnl( 1 );
   #else
      LPNMHEADER lpnmheader = ( LPNMHEADER ) hb_parnll( 1 );
   #endif

   hb_retnll( lpnmheader->iItem );
}


HB_FUNC( LV_GETNEXTITEM )                        // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retni( ListView_GetNextItem( hWnd, (int) (hb_parni(2)-1) , LVNI_ALL | LVNI_SELECTED ) + 1 );
}

HB_FUNC( LV_GETSELECTEDCOUNT )                   // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   #ifdef AVOID_COMPILER_WARNING
      hb_retnll( SendMessage( hWnd, LVM_GETSELECTEDCOUNT, 0, 0) ) ;
   #else
      hb_retnll( ListView_GetSelectedCount(hWnd) );
   #endif
}

HB_FUNC( LV_GETSELECTIONMARK )                   // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   #ifdef AVOID_COMPILER_WARNING
      hb_retnll( SendMessage( hWnd, LVM_GETSELECTIONMARK, 0, 0) ) ;
   #else
      hb_retnll( ListView_GetSelectionMark(hWnd) );
   #endif
}

HB_FUNC( LV_GETTEXTCOLOR )                       // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retnl ( ListView_GetTextColor ( hWnd ) ) ;
}

HB_FUNC( LV_GETTOPINDEX )                        // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retnl ( ListView_GetTopIndex ( hWnd ) ) ;
}

HB_FUNC( LV_GETSUBITEMRECT )                     // ok
{
   RECT Rect;
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   int  iItem    = (int)  hb_parni (2);   // Index of the subitem's parent item
   int  iSubItem = (int)  hb_parni (3);   // The one-based index of the subitem
   int  code     = (int)  LVIR_BOUNDS;    // A portion of the list-view subitem for which to retrieve the bounding rectangle information

   #ifdef AVOID_COMPILER_WARNING
      Rect.top  = iSubItem;
      Rect.left = code;
      SendMessage ( hWnd, LVM_GETSUBITEMRECT, (WPARAM) iItem, (LPARAM) &Rect );
   #else
      ListView_GetSubItemRect ( hWnd, iItem, iSubItem, code, &Rect ) ;
   #endif

   hb_reta( 4 );
   hb_storvni( Rect.top  , -1, 1 );
   hb_storvni( Rect.left  , -1, 2 );
   hb_storvni( Rect.right - Rect.left , -1, 3 );
   hb_storvni( Rect.bottom - Rect.top  , -1, 4 );
}

HB_FUNC( LV_GETITEMRECT )                        // ok
{
   RECT Rect ;
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   int  i    = (int)  hb_parni (2);   // The index of the list-view item
   int  code = (int)  LVIR_LABEL;     // The portion of the list-view item from which to retrieve the bounding rectangle

   #ifdef AVOID_COMPILER_WARNING
      Rect.left = code;
      SendMessage ( hWnd, LVM_GETITEMRECT, (WPARAM) i, (LPARAM) &Rect );
   #else
      ListView_GetItemRect ( hWnd, i, &Rect, code );
   #endif

   hb_reta( 4 );
   hb_storvni( Rect.top  , -1, 1 );
   hb_storvni( Rect.left  , -1, 2 );
   hb_storvni( Rect.right - Rect.left , -1, 3 );
   hb_storvni( Rect.bottom - Rect.top  , -1, 4 );
}

// ListView_GetExtendedStyle ( hWnd, [ nExStyle ] )
HB_FUNC( LV_GETEXTENDEDSTYLE )                   // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   DWORD ExStyle  = (DWORD) hb_parnl  (2);
   DWORD OldStyle = ListView_GetExtendedListViewStyle (hWnd);
   if ( HB_ISNUM(2) )
      hb_retl ((BOOL) ((OldStyle & ExStyle) == ExStyle));
   else
      hb_retnl ((LONG) OldStyle);
}


HB_FUNC( LV_GETGRIDROW )                         // ok
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   NM_LISTVIEW * NMLV = (NM_LISTVIEW *) lParam;
   hb_retni ( NMLV->iItem );
}


HB_FUNC( LV_GETGRIDOLDSTATE )                    // ok
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   NM_LISTVIEW * NMLV = (NM_LISTVIEW *) lParam;
   hb_retni ( NMLV->uOldState );
}


HB_FUNC( LV_GETGRIDNEWSTATE )                    // ok
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   NM_LISTVIEW * NMLV = (NM_LISTVIEW *) lParam;
   hb_retni ( NMLV->uNewState );
}


HB_FUNC( LV_HIDEWINDOW )                         // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retnl( ShowWindow(hWnd, SW_HIDE) );
}

HB_FUNC( LV_HITTEST )                            // ok
{

   POINT point ;
   LVHITTESTINFO lvhti;

   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   point.y = hb_parni(2) ;
   point.x = hb_parni(3) ;

   lvhti.pt = point;

//   ListView_SubItemHitTest ( hWnd, &lvhti ) ;
   ListView_HitTest(hWnd, &lvhti ) ;

   if(lvhti.flags & LVHT_ONITEM)
   {
      hb_reta( 2 );
      hb_storvni( lvhti.iItem + 1 , -1, 1 );
      hb_storvni( lvhti.iSubItem + 1 , -1, 2 );
   }
   else
   {
      hb_reta( 2 );
      hb_storvni( 0 , -1, 1 );
      hb_storvni( 0 , -1, 2 );
   }
}

// LV_INSERTCOLUMN( hWnd, nSubItem, nWeight, cText, nFMT )
HB_FUNC( LV_INSERTCOLUMN )                       // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif

   LV_COLUMN COL;

   COL.mask= LVCF_WIDTH | LVCF_TEXT | LVCF_FMT | LVCF_SUBITEM | LVCF_IMAGE ;
//   | LVCF_IMAGE ;
   COL.cx= hb_parni(3);
   COL.pszText = (TCHAR*) hb_parc(4);
   COL.iSubItem=hb_parni(2)-1;
   COL.fmt = hb_parni(5) ;
   COL.iImage = hb_parni(6);

   ListView_InsertColumn ( hWnd, hb_parni(2)-1, &COL );

}


HB_FUNC( LV_INITCOMMON )                         // ok
{
   INITCOMMONCONTROLSEX i;

   memset( ( char * ) &i, 0, sizeof( INITCOMMONCONTROLSEX ) );

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_LISTVIEW_CLASSES;

}


HB_FUNC( LV_REDRAWITEMS )                        // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retnl ( ListView_RedrawItems ( hWnd, hb_parni(2) , hb_parni(3) ) ) ;
}

// LV_Scroll ( hWnd, nDx, nDy )
HB_FUNC( LV_SCROLL )                             // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   ListView_Scroll( hWnd, hb_parni(2), hb_parni(3) ) ;
}

HB_FUNC( LV_SETBKCOLOR )                         // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   ListView_SetBkColor ( hWnd, (COLORREF) RGB(hb_parni(2), hb_parni(3), hb_parni(4)) ) ;
}

// LV_SETITEMCOUNT( hWnd, nMax )
HB_FUNC( LV_SETITEMCOUNT )                       // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   INT  nItemCount = (INT) hb_parni (2);

//   SendMessage ( hWnd, LVM_SETITEMCOUNT, (WPARAM) hb_parni (2), (LPARAM) 0 );
   if ( (GetWindowLongPtr (hWnd, GWL_STYLE) & LVS_OWNERDATA) == LVS_OWNERDATA )   // ADD3, July 2015
       ListView_SetItemCountEx (hWnd, nItemCount, LVSICF_NOINVALIDATEALL);
   else
       ListView_SetItemCount (hWnd, nItemCount);
}

// LV_SETITEMSELECT( hWnd, nPosi )
HB_FUNC( LV_SETITEMSELECT )                      // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif

   ListView_EnsureVisible( hWnd, hb_parnl( 2 ) -1, FALSE );
   ListView_SetItemState( hWnd, -1, 0, LVIS_SELECTED );
   ListView_SetItemState( hWnd, hb_parnl( 2 ) -1, ( LVIS_SELECTED | LVIS_FOCUSED ), ( LVIS_SELECTED | LVIS_FOCUSED ) );
}

HB_FUNC( LV_SETITEMSTATE)                        // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   ListView_SetItemState( hWnd, (int) (hb_parni(2)-1) , hb_parni(3) , hb_parni(4) );
}

HB_FUNC( LV_SETTEXTBKCOLOR )                     // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   ListView_SetTextBkColor ( hWnd, (COLORREF) RGB(hb_parni(2), hb_parni(3), hb_parni(4)) ) ;
}

HB_FUNC( LV_SETTEXTCOLOR )                       // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   ListView_SetTextColor ( hWnd, (COLORREF) RGB(hb_parni(2), hb_parni(3), hb_parni(4)) ) ;
}

// LV_SetItemText (hWnd, aItem, nRow)
HB_FUNC( LV_SETITEMTEXT )                        // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   WORD nLen = ( WORD ) hb_parinfa (2, 0);
   int  nRow = hb_parni (3) - 1;
   TCHAR *cText;
   int nCol;

   for (nCol=0 ; nCol < nLen ; nCol++ )
   {
      cText = (TCHAR*) hb_parvc (2 , nCol + 1);
      ListView_SetItemText (hWnd, nRow, nCol, cText);
   }
}

// LV_SHOWWINDOW(hWnd)
HB_FUNC( LV_SHOWWINDOW )                         // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retnl( ShowWindow(hWnd, SW_SHOW) );
}



//        LV_SetHeaderImageIndex (hWnd, nCol, nIndex)
HB_FUNC( LV_SETHEADERIMAGEINDEX )                // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   INT  nCol    = (INT)  hb_parni  (2);
   INT  nIndex  = (INT)  hb_parni  (3);
   LV_COLUMN LVC;
   LVC.mask   = LVCF_FMT | LVCF_IMAGE;
   LVC.iImage = nIndex;
   LVC.fmt    = LVCFMT_IMAGE /*| LVCFMT_COL_HAS_IMAGES*/;
   ListView_SetColumn (hWnd, nCol , &LVC);
}

// ListView_SetSortHeaderAll ( nHWndLV, nColumn , nType, hIcon )
//  /*0==none, positive==UP arrow or negative==DOWN arrow*/] ) -> nType (previous setting)
HB_FUNC( LV_SETSORTHEADERDLL )                   // ok
{
   #ifndef _WIN64
      HWND hWndHD = ( HWND ) SendMessage( ( HWND ) hb_parnl( 1 ), LVM_GETHEADER, 0, 0 );
   #else
      HWND hWndHD = ( HWND ) SendMessage( ( HWND ) hb_parnll( 1 ), LVM_GETHEADER, 0, 0 );
   #endif
   INT    nItem  = hb_parni( 2 ) - 1;
   INT    nType;
   HDITEM hdItem;

   {
      hdItem.mask = HDI_IMAGE | HDI_FORMAT;

      SendMessage( hWndHD, HDM_GETITEM, nItem, ( LPARAM ) &hdItem );

      nType = hb_parni( 3 );

      if( nType == 0 )
      {
         hdItem.mask = HDI_FORMAT;
         hdItem.fmt &= ~( HDF_IMAGE | HDF_BITMAP_ON_RIGHT );
      }
      else
      {
         if( nType > 0 )
            hdItem.hbm = (HBITMAP) hb_parnll(4) ;
         else
            hdItem.hbm = ( HBITMAP ) hb_parnll(4) ;

         hdItem.fmt |= HDF_IMAGE ;
         if( hdItem.fmt & HDF_RIGHT )
            hdItem.fmt &= ~HDF_BITMAP_ON_RIGHT;
         else
            hdItem.fmt |= HDF_BITMAP_ON_RIGHT;
      }

      SendMessage( hWndHD, HDM_SETITEM, nItem, ( LPARAM ) &hdItem );
   }
}


// ListView_SetSortHeaderIco ( nHWndLV, nColumn [, nType
//  /*0==none, positive==UP arrow or negative==DOWN arrow*/] ) -> nType (previous setting)
HB_FUNC( LV_SETSORTHEADERICO )                   // ok
{
   #ifndef _WIN64
      HWND hWndHD = ( HWND ) SendMessage( ( HWND ) hb_parnl( 1 ), LVM_GETHEADER, 0, 0 );
   #else
      HWND hWndHD = ( HWND ) SendMessage( ( HWND ) hb_parnll( 1 ), LVM_GETHEADER, 0, 0 );
   #endif
   INT    nItem  = hb_parni( 2 ) - 1;
   INT    nType;
   HDITEM hdItem;

   if( hb_parl( 4 ) )
   {
      hdItem.mask = HDI_FORMAT;

      SendMessage( hWndHD, HDM_GETITEM, nItem, ( LPARAM ) &hdItem );

      if( hdItem.fmt & HDF_SORTUP )
         hb_retni( 1 );
      else if( hdItem.fmt & HDF_SORTDOWN )
         hb_retni( -1 );
      else
         hb_retni( 0 );

      if( ( hb_pcount() > 2 ) && HB_ISNUM( 3 ) )
      {
         nType = hb_parni( 3 );

         if( nType == 0 )
            hdItem.fmt &= ~( HDF_SORTDOWN | HDF_SORTUP );
         else if( nType > 0 )
            hdItem.fmt = ( hdItem.fmt & ~HDF_SORTDOWN ) | HDF_SORTUP;
         else
            hdItem.fmt = ( hdItem.fmt & ~HDF_SORTUP ) | HDF_SORTDOWN;

         SendMessage( hWndHD, HDM_SETITEM, nItem, ( LPARAM ) &hdItem );
      }
   }
   else
   {
      hdItem.mask = HDI_IMAGE | HDI_FORMAT;

      SendMessage( hWndHD, HDM_GETITEM, nItem, ( LPARAM ) &hdItem );

      nType = hb_parni( 3 );

      if( nType == 0 )
      {
         hdItem.mask = HDI_FORMAT;
         hdItem.fmt &= ~( HDF_IMAGE | HDF_BITMAP_ON_RIGHT );
      }
      else
      {
         if( nType > 0 )
            hdItem.hbm = ( HBITMAP ) LoadImage( ( HINSTANCE ) NULL, TEXT( "ICOUP" )   ,   IMAGE_ICON, 0, 0, LR_LOADTRANSPARENT | LR_DEFAULTCOLOR | LR_LOADMAP3DCOLORS | LR_COPYFROMRESOURCE );
         else
            hdItem.hbm = ( HBITMAP ) LoadImage( ( HINSTANCE ) NULL, TEXT( "ICONDOWN" ),   IMAGE_ICON, 0, 0, LR_LOADTRANSPARENT | LR_DEFAULTCOLOR | LR_LOADMAP3DCOLORS | LR_COPYFROMRESOURCE );

         hdItem.fmt |= HDF_IMAGE ;
         if( hdItem.fmt & HDF_RIGHT )
            hdItem.fmt &= ~HDF_BITMAP_ON_RIGHT;
         else
            hdItem.fmt |= HDF_BITMAP_ON_RIGHT;
      }

      SendMessage( hWndHD, HDM_SETITEM, nItem, ( LPARAM ) &hdItem );
   }
}

// LV_GETCOLUMNWIDTH(hWnd, nCol, nwide)          // nCol = Zero-based
HB_FUNC( LV_SETCOLUMNWIDTH )                     // ok
{
   #ifndef _WIN64
      HWND hGrid = ( HWND ) hb_parnl( 1 );
   #else
      HWND hGrid = ( HWND ) hb_parnll( 1 );
   #endif
   ListView_SetColumnWidth ( hGrid, hb_parni(2) , hb_parni(3) ) ;
}


// LV_SETCHECKSTATE (hWnd, nRow, lCheck)
HB_FUNC( LV_SETCHECKSTATE)                       // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   UINT nRow   = (UINT) hb_parnl (2);
   BOOL lCheck = (BOOL) hb_parl  (3);

   ListView_SetCheckState (hWnd, nRow-1, lCheck);
}

// LV_SETGRIDQUERYDATA(nPtrNMHDR)
HB_FUNC( LV_SETGRIDQUERYDATA )                   // ok
{
   #ifndef _WIN64
      LPARAM lParam = ( LPARAM ) hb_parnl( 1 );
   #else
      LPARAM lParam = ( LPARAM ) hb_parnll( 1 );
   #endif
   LV_DISPINFO * pDispInfo = ( LV_DISPINFO * ) lParam;

   // Copy the text to the LV_ITEM structure
   // Maximum number of characters is in pDispInfo->Item.cchTextMax
#ifdef UNICODE
   LPWSTR lpText = AnsiToWide( ( TCHAR * ) hb_parc( 2 ) );
   lstrcpyn( pDispInfo->item.pszText, ( TCHAR * ) lpText, pDispInfo->item.cchTextMax );
   hb_xfree( lpText );
#else
   lstrcpyn( pDispInfo->item.pszText, ( TCHAR * ) hb_parc( 2 ), pDispInfo->item.cchTextMax );
#endif
}

// LV_SETGRIDQUERYIMAGE(nPtrNMHDR)
HB_FUNC( LV_SETGRIDQUERYIMAGE )                  // ok
{
   #ifndef _WIN64
      LPARAM lParam = ( LPARAM ) hb_parnl( 1 );
   #else
      LPARAM lParam = ( LPARAM ) hb_parnll( 1 );
   #endif
   LV_DISPINFO * pDispInfo = ( LV_DISPINFO * ) lParam;

   pDispInfo->item.iImage = hb_parni( 2 );
}


HB_FUNC( LV_SETCHECKITEM )                       // ok
{
   #ifndef _WIN64
      LPARAM lParam = ( LPARAM ) hb_parnl( 1 );
   #else
      LPARAM lParam = ( LPARAM ) hb_parnll( 1 );
   #endif
   LV_DISPINFO * pDispInfo = ( LV_DISPINFO * ) lParam;

   //Create a pointer to the item
   LV_ITEM* pItem= &(pDispInfo)->item;

   //To enable check box, we have to enable state mask...
   pItem->mask |= LVIF_STATE;
   pItem->stateMask = LVIS_STATEIMAGEMASK;

   pItem->state = INDEXTOSTATEIMAGEMASK( hb_parni( 2 ) );
   //pItem->state = INDEXTOSTATEIMAGEMASK( 2 );

}

HB_FUNC( LV_UPDATE )                             // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   hb_retnl( ListView_Update ( hWnd, hb_parni(2) - 1 ) );
}


//        ListView_SetItemImageIndex ( hWnd , nRow , nCol, [ nImageIndex ] )
HB_FUNC( LV_SETITEMIMAGEINDEX )                  // ok
{
   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   int nRow   = (int)  hb_parni  (2);
   int nCol   = (int)  hb_parni  (3);   // LVM_SETEXTENDEDLISTVIEWSTYLE with LVS_EX_SUBITEMIMAGES
   int iImage = HB_ISNIL(4) ? -1 : hb_parni (4);

   LV_ITEM LV;
   LV.mask      = LVIF_IMAGE;
   LV.state     = 0;
   LV.stateMask = 0;
   LV.iImage    = iImage;
   LV.iSubItem  = nCol;
   LV.iItem     = nRow;

   ListView_SetItem (hWnd, &LV);
}


HB_FUNC( LV_INITLISTVIEW )                       // ok
{
   HWND hwnd;
   HWND hbutton;
   int  style;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_LISTVIEW_CLASSES;
   InitCommonControlsEx( &i );

   hwnd = ( HWND ) hb_parnll( 1 );

   style = LVS_SHOWSELALWAYS | WS_CHILD | WS_VISIBLE | LVS_REPORT;

   if( ! hb_parl( 9 ) )
      style = style | LVS_SINGLESEL;

   if( ! hb_parl( 12 ) )
      style = style | WS_TABSTOP;

   if( ! hb_parl( 10 ) )
      style = style | LVS_NOCOLUMNHEADER;
   else if( hb_parl( 11 ) )
      style = style | LVS_NOSORTHEADER;

   if( hb_parl( 7 ) )
      style = style | LVS_OWNERDATA;

   hbutton = CreateWindowEx
             (
      WS_EX_CLIENTEDGE,
      WC_LISTVIEW,
      TEXT( "" ),
      style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hwnd,
      ( HMENU ) hb_parnll( 2 ),
      GetModuleHandle(NULL),
      NULL
             );

   if( hb_parl( 7 ) )
      ListView_SetItemCount( hbutton, hb_parni( 8 ) );

   hb_retnll( ( LONG_PTR ) hbutton );
}


//********************************************************************************************************
// ListView Custom Draw
//********************************************************************************************************


//        Header_SetFont
HB_FUNC( HEADER_SETFONT )                        // ok
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   LPNMCUSTOMDRAW lpNMCustomDraw = (LPNMCUSTOMDRAW) lParam;
   HFONT hFont = (HFONT) hb_parnll (4);

//   SetBkMode    (lpNMCustomDraw->hdc, OPAQUE);
   SetBkColor   (lpNMCustomDraw->hdc, hb_parni(2));   // Not work
   SetTextColor (lpNMCustomDraw->hdc, hb_parni(3));

   if ( hFont != NULL )
       SelectObject (lpNMCustomDraw->hdc, hFont);

   hb_retni ( CDRF_NEWFONT );
}

//        Header_SetColor
HB_FUNC( HEADER_SETCOLOR )
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   LPNMCUSTOMDRAW lpNMCustomDraw = (LPNMCUSTOMDRAW) lParam;
   HBRUSH hbrush;
   RECT rect = lpNMCustomDraw->rc ;

   SetBkColor   (lpNMCustomDraw->hdc, hb_parni(2));
   SetTextColor (lpNMCustomDraw->hdc, hb_parni(3));

   hbrush = CreateSolidBrush( hb_parni(2) );
   SetBkMode( lpNMCustomDraw->hdc, 1 );
   SelectObject( lpNMCustomDraw->hdc, hbrush);
   FillRect(lpNMCustomDraw->hdc, &rect , hbrush);
   DeleteObject(hbrush);

   hb_retni ( CDRF_NEWFONT );
}

//        Header_CustomDraw_GetItem ( lParam ) --> nColumnHeader
HB_FUNC( HEADER_CUSTOMDRAW_GETITEM )
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   LPNMCUSTOMDRAW lpNMCustomDraw = (LPNMCUSTOMDRAW) lParam;
   hb_retnll( ( LONG_PTR ) lpNMCustomDraw->dwItemSpec );
}

//        Header_CustomDraw_GetAction ( lParam )
HB_FUNC( HEADER_CUSTOMDRAW_GETACTION )
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   LPNMCUSTOMDRAW lpNMCustomDraw = (LPNMCUSTOMDRAW) lParam;

   if ( lpNMCustomDraw->dwDrawStage == CDDS_PREPAINT )
       hb_retni ( CDRF_NOTIFYITEMDRAW ) ;
   else if ( lpNMCustomDraw->dwDrawStage == CDDS_ITEMPREPAINT )   // not work in 64-bits, never dwDrawStage == CDDS_ITEMPREPAINT ???
        hb_retni ( -1 ) ;   // Change font, forecolor , backcolor
   else
      hb_retni ( CDRF_DODEFAULT ) ;
}

//        Header_CustomDraw_GetHDC ( lParam ) --> hDC
HB_FUNC( HEADER_CUSTOMDRAW_GETHDC )
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   LPNMCUSTOMDRAW lpNMCustomDraw = (LPNMCUSTOMDRAW) lParam;
   hb_retnll( ( LONG_PTR ) lpNMCustomDraw->hdc);
}

//        ListView_CustomDraw_GetHDC ( lParam ) --> hDC
HB_FUNC( LISTVIEW_CUSTOMDRAW_GETHDC )
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   LPNMLVCUSTOMDRAW lplvcd = (LPNMLVCUSTOMDRAW) lParam;
   hb_retnll( ( LONG_PTR ) lplvcd->nmcd.hdc);
}


//        ListView_CustomDraw_GetAction ( lParam , [ CellNavigation , hWndLV , nIndex ] )
HB_FUNC( LISTVIEW_CUSTOMDRAW_GETACTION )
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   LPNMLVCUSTOMDRAW lplvcd = (LPNMLVCUSTOMDRAW) lParam;

   if (lplvcd->nmcd.dwDrawStage == CDDS_PREPAINT )
       hb_retni ( CDRF_NOTIFYITEMDRAW ) ;

   else if (lplvcd->nmcd.dwDrawStage == CDDS_ITEMPREPAINT )
   {
        if ( hb_parl (2) )   // if CellNavigation == .T.
        {
   #ifndef _WIN64
            HWND hWndLV = (HWND) hb_parnl (3);
   #else
            HWND hWndLV = (HWND) hb_parnll (3);
   #endif
            INT  nIndex = (INT)  hb_parni  (4) - 1;
            if ( ListView_GetNextItem (hWndLV, - 1, (LVNI_ALL | LVNI_SELECTED)) == nIndex )
                ListView_SetItemState(hWndLV, nIndex, 0, LVIS_SELECTED );
        }

        hb_retni ( CDRF_NOTIFYSUBITEMDRAW ) ;
   }
   else if (lplvcd->nmcd.dwDrawStage == (CDDS_SUBITEM | CDDS_ITEMPREPAINT))
        hb_retni ( -1 ) ;   // Change font, forecolor , backcolor
   else
      hb_retni ( CDRF_DODEFAULT ) ;
}

//        ListView_CustomDraw_GetRowCol ( lParam ) --> { nRow , nCol }
HB_FUNC( LISTVIEW_CUSTOMDRAW_GETROWCOL )
{
   #ifndef _WIN64
      LPARAM lParam = (LPARAM) hb_parnl (1);
   #else
      LPARAM lParam = (LPARAM) hb_parnll (1);
   #endif
   LPNMLVCUSTOMDRAW lplvcd = (LPNMLVCUSTOMDRAW) lParam;

   hb_reta( 2 );
   // nRow draw
   hb_storvnl( (LONG) lplvcd->nmcd.dwItemSpec + 1 , -1, 1 );   // The item number. What is contained in this member will depend on the type of control
                                                               // that is sending the notification. See the NM_CUSTOMDRAW notification reference for
                                                               // the specific control to determine what, if anything, is contained in this member.
   // nCol draw
   hb_storvnl( (LONG) lplvcd->iSubItem + 1 , -1, 2 );   // Index of the subitem that is being drawn.
                                                        // If the main item is being drawn, this member will be zero.
}

#pragma ENDDUMP

*
*
*
