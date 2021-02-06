
#include <winrt/Windows.UI.Notifications.h>
#include <winrt/Windows.Data.Xml.Dom.h>

#include <iostream>
#include <locale>
#include <codecvt>

using std::cerr;
static std::wbuffer_convert<std::codecvt_utf8_utf16<wchar_t>>
  converting_stderr_buf{ cerr.rdbuf() };
std::wostream wcerr{ &converting_stderr_buf };

template<std::wostream &Stream>
struct wflusher { ~wflusher(){ Stream.flush(); } };
static wflusher<wcerr> wcerr_flusher;

using std::wstring_view;
using namespace std::string_view_literals;


int main() try
{
  using namespace winrt::Windows::UI::Notifications;
  using mgr = ToastNotificationManager;

  auto toastdoc = mgr::GetTemplateContent( ToastTemplateType::ToastText01 );
  toastdoc.SelectSingleNode(L"//text").InnerText(L"hello world");

  wcerr <<"markup: LR\"("<< wstring_view{toastdoc.GetXml()} <<")\"\n";

  const auto aumid = L"mjk.YoloRT.NaughtyExample"sv; //application user model ID
  mgr::CreateToastNotifier(aumid).Show( ToastNotification{toastdoc} );

  /*
    For the notification to be shown, the AUMID needs to have been registered
    in the system, which is currently outside the scope of this example. One
    (the only?) way to do that is putting an AUMID-bearing shortcut into the
    start menu. See, e.g., https://docs.microsoft.com/en-us/previous-versions\
/windows/desktop/legacy/hh802762(v=vs.85)
  */
}
catch ( const winrt::hresult_error &e )
{
  wcerr <<"error 0x"<< std::hex << e.code() <<": "<<
    wstring_view{e.message()} << '\n';
  return 1;
}
catch ( const std::exception &e )
{
  cerr << e.what() << '\n';
  return 1;
}
