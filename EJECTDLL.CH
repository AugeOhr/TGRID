
#define NULL							0

#define SW_HIDE 0
#define SW_SHOWNORMAL 1
#define SW_NORMAL 1
#define SW_SHOWMINIMIZED 2
#define SW_SHOWMAXIMIZED 3
#define SW_MAXIMIZE 3
#define SW_SHOWNOACTIVATE 4
#define SW_SHOW 5
#define SW_MINIMIZE 6
#define SW_SHOWMINNOACTIVE 7
#define SW_SHOWNA 8
#define SW_RESTORE 9
#define SW_SHOWDEFAULT 10
#define SW_FORCEMINIMIZE 11
#define SW_MAX 11
#define SW_PARENTCLOSING 1
#define SW_OTHERZOOM 2
#define SW_PARENTOPENING 3
#define SW_OTHERUNZOOM 4

#define DLL_CDECL                   0x08
#define DLL_STDCALL                 0x20
#define DLL_SYSTEM                  0x04
#if defined( __PLATFORM__WINDOWS )
#define DLL_OSAPI                   DLL_STDCALL
#elif defined( __PLATFORM__OS2 )
#define DLL_OSAPI                   DLL_SYSTEM
#else
#define DLL_OSAPI                   DLL_CDECL
#endif

#define SE_ERR_FNF                     2  // File not found.
#define SE_ERR_PNF                     3  // Path not found.
#define SE_ERR_ACCESSDENIED            5  // Access denied.
#define SE_ERR_OOM                     8  // Out of memory.
#define SE_ERR_SHARE                   26 // Cannot share an open file.
#define SE_ERR_ASSOCINCOMPLETE         27 // File association information not complete.
#define SE_ERR_DDETIMEOUT              28 // DDE operation timed out.
#define SE_ERR_DDEFAIL                 29 // DDE operation failed.
#define SE_ERR_DDEBUSY                 30 // DDE operation is busy.
#define SE_ERR_NOASSOC                 31 // File association not available.
#define SE_ERR_DLLNOTFOUND             32 // Dynamic-link library not found.

#define FSCTL_LOCK_VOLUME              0x00090018
#define FSCTL_UNLOCK_VOLUME            0x0009001C
#define FSCTL_DISMOUNT_VOLUME          0x00090020

#define IOCTL_STORAGE_EJECT_MEDIA      0x002D4808  // IOCTL_DISK_EJECT_MEDIA
#define IOCTL_STORAGE_MEDIA_REMOVAL    0x002D4804

#define FILE_SHARE_READ                   0x00000001
#define FILE_SHARE_WRITE                  0x00000002
#define FILE_SHARE_DELETE                 0x00000004
#define FILE_SHARE_VALID_FLAGS            0x00000007

#define GENERIC_READ                      0x80000000
#define GENERIC_WRITE                     0x40000000
#define GENERIC_EXECUTE                   0x20000000
#define GENERIC_ALL                       0x10000000

#define OPEN_EXISTING                     3

#define DRIVE_UNKNOWN                   0
#define DRIVE_NO_ROOT_DIR               1
#define DRIVE_REMOVABLE                 2
#define DRIVE_FIXED                     3
#define DRIVE_REMOTE                    4
#define DRIVE_CDROM                     5
#define DRIVE_RAMDISK                   6


