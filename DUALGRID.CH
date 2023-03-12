#define DLL_CDECL                       0x08
#define DLL_STDCALL                     0x20
#define DLL_SYSTEM                      0x04
#if defined( __PLATFORM__WINDOWS )
#define DLL_OSAPI                       DLL_STDCALL
#elif defined( __PLATFORM__OS2 )
#define DLL_OSAPI                       DLL_SYSTEM
#else
#define DLL_OSAPI                       DLL_CDECL
#endif

#define nUseButton                      12

//  #define CSIDL_COMMON_DESKTOPDIRECTORY   0x0019

#define CF_TEXT                         1

#define EM_SETSEL                       0x00B1

#define FILE_ATTRIBUTE_READONLY         0x00000001
#define FILE_ATTRIBUTE_HIDDEN           0x00000002
#define FILE_ATTRIBUTE_SYSTEM           0x00000004
#define FILE_ATTRIBUTE_DIRECTORY        0x00000010
#define FILE_ATTRIBUTE_ARCHIVE          0x00000020
#define FILE_ATTRIBUTE_DEVICE           0x00000040
#define FILE_ATTRIBUTE_NORMAL           0x00000080

//  #define SW_HIDE                     0
//  #define SW_NORMAL                   1
//  #define SW_SHOW                     5

#define HWND_TOP                        0
#define HWND_BOTTOM                     1
#define HWND_TOPMOST                    -1
#define HWND_NOTOPMOST                  -2

#define MB_TOPMOST                      0x00040000

#define SWP_NOSIZE                      0x0001
#define SWP_NOMOVE                      0x0002

#define SRCPAINT                        15597702   // 0xEE0086
#define SRCAND                          8913094

#define LWA_COLORKEY                    1
#define GWL_EXSTYLE                     -20
#define WS_EX_LAYERED                   524288

#define MK_SHIFT                        0x0004
#define MK_CONTROL                      0x0008
#define MK_MBUTTON                      0x0010

#define DRIVE_UNKNOWN                   0
#define DRIVE_NO_ROOT_DIR               1
#define DRIVE_REMOVABLE                 2
#define DRIVE_FIXED                     3
#define DRIVE_REMOTE                    4
#define DRIVE_CDROM                     5
#define DRIVE_RAMDISK                   6

#define SIZE_INIT                       NIL
#define SIZE_RESTORED                   0
#define SIZE_MINIMIZED                  1
#define SIZE_MAXIMIZED                  2

#define RESOURCETYPE_ANY                0
#define RESOURCETYPE_DISK               1
#define RESOURCETYPE_PRINT              2

#DEFINE LANG_LOCALE                     1
#DEFINE LANG_LANGCODE                   2
#DEFINE LANG_LCIDSTRING                 3
#DEFINE LANG_LCIDDECIMAL                4
#DEFINE LANG_LCIDHEX                    5
#DEFINE LANG_CODEPAGE                   6
#DEFINE LANG_LANGWIN                    7

#DEFINE X_COUNTRY                       1
#DEFINE X_NUM1                          2
#DEFINE X_CDP1                          3
#DEFINE X_ISO1                          4
#DEFINE X_ISO2                          5
#DEFINE X_CODEPAGE                      6


#define DT_VCENTER                      4
#define DT_SINGLELINE                   32
#define DT_CENTER                       1

#define BMP_HANDLE                      1
#define BMP_WIDTH                       2
#define BMP_HEIGHT                      3

#define LAYOUT_TOP                      1
#define LAYOUT_LEFT                     2
#define LAYOUT_BOTTOM                   3
#define LAYOUT_RIGHT                    4

#define WM_POWERBROADCAST               0x0218
#define PBT_APMQUERYSUSPEND             0x0000
#define PBT_APMQUERYSTANDBY             0x0001
#define PBT_APMQUERYSUSPENDFAILED       0x0002
#define PBT_APMQUERYSTANDBYFAILED       0x0003
#define PBT_APMSUSPEND                  0x0004
#define PBT_APMSTANDBY                  0x0005
#define PBT_APMRESUMECRITICAL           0x0006
#define PBT_APMRESUMESUSPEND            0x0007
#define PBT_APMRESUMESTANDBY            0x0008
#define PBTF_APMRESUMEFROMFAILURE       0x00000001
#define PBT_APMBATTERYLOW               0x0009
#define PBT_APMPOWERSTATUSCHANGE        0x000A
#define PBT_APMOEMEVENT                 0x000B
#define PBT_APMRESUMEAUTOMATIC          0x0012

#define DT_LEFT                         0x00000000
#define DT_WORDBREAK                    0x00000010
#define DT_NOPREFIX                     0x00000800

#define ODA_DRAWENTIRE                  0x0001
#define ODA_SELECT                      0x0002
#define ODA_FOCUS                       0x0004

#define ODT_LISTBOX                     2
#define ODT_COMBOBOX                    3

#define ODS_SELECTED                    0x0001
#define ODS_FOCUS                       0x0010
#define ODS_DEFAULT                     0x0020

#define CB_SETCURSEL                    0x014E

#define DI_IMAGE                        0x0002
#define DI_NORMAL                       0x0003

#define DFC_BUTTON                      4
#define DFCS_BUTTONCHECK                0x0000
#define DFCS_HOT                        0x1000

#define CCM_FIRST                       0x2000
#define CCM_SETBKCOLOR                  (CCM_FIRST + 1)
#define SB_SETBKCOLOR                   CCM_SETBKCOLOR

// ListView Array
//
#define LV_NAME                         1
#define LV_EXT                          2
#define LV_SIZE                         3
#define LV_DATE                         4
#define LV_TIME                         5
#define LV_ATTR                         6
