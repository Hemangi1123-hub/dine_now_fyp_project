import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hotel_management/pages/Owner/upload_page.dart';
import 'package:hotel_management/services/crud.dart';

class ResturantPage extends StatelessWidget {
  ResturantPage({super.key});
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController restaurantController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    Future openDialogName() => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Change Name'),
            content: SizedBox(
              width: 250, // Adjust the width as needed
              height: 150, // Adjust the height as needed
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Makes the column take up minimal space
                children: [
                  TextField(
                    controller: restaurantController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Enter name',
                    ),
                  ),
                  SizedBox(
                      height:
                          10), // Add some spacing between the TextField and the button
                  ElevatedButton(
                    onPressed: () {
                      
                      String uid = currentUser!.uid;

                      firestoreService.addRestaurant(
                          context, uid, restaurantController.text);
                      restaurantController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
    Future openDialogLocation() => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Set Location'),
            content: SizedBox(
              width: 250, // Adjust the width as needed
              height: 150, // Adjust the height as needed
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Makes the column take up minimal space
                children: [
                  TextField(
                    controller: locationController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Enter name',
                    ),
                  ),
                  SizedBox(
                      height:
                          10), // Add some spacing between the TextField and the button
                  ElevatedButton(
                    onPressed: () {
                      firestoreService.addLocation(context,
                          currentUser!.uid.toString(), locationController.text);
                      locationController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text("Resturant Settings",
                    style: Theme.of(context).textTheme.headlineMedium),
                Text(
                  "Update your Resturant info like description, photos, edit etc.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ProfileMenuCard(
                  svgSrc: restaurantIconSvg,
                  title: "Resturant Information",
                  subTitle: "Change your Resturant information",
                  press: () {
                    openDialogName();
                  },
                ),
                ProfileMenuCard(
                  svgSrc: photoFrameSvg,
                  title: "Change Photos",
                  subTitle: "Change the resturan't photos",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadPage(
                          user: currentUser!.uid, // Pass the dynamic value here
                        ),
                      ),
                    );
                  },
                ),
                ProfileMenuCard(
                  svgSrc: markerIconSvg,
                  title: "Locations",
                  subTitle: "Add or remove your delivery locations",
                  press: () {
                    openDialogLocation();
                  },
                ),
                ProfileMenuCard(
                  svgSrc: shareIconSvg,
                  title: "Add Menu Items",
                  subTitle: "Add food, description and price",
                  press: () {
                    Navigator.pushNamed(context, '/addmenu');
                  },
                ),
                ProfileMenuCard(
                  svgSrc: shareIconSvg,
                  title: "Approve Request",
                  subTitle: "Accept Decline Chefs Request",
                  press: () {
                    Navigator.pushNamed(context, '/acceptdecline');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({
    super.key,
    this.title,
    this.subTitle,
    this.svgSrc,
    this.press,
  });

  final String? title, subTitle, svgSrc;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: press,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SvgPicture.string(
                svgSrc!,
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subTitle!,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF010F07).withOpacity(0.54),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_outlined,
                size: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}

const String lineIconSvg = '''
'<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <title>LINE</title>
  <path d="M19.365 9.863c.349 0 .63.285.63.631 0 .345-.281.63-.63.63H17.61v1.125h1.755c.349 0 .63.283.63.63 0 .344-.281.629-.63.629h-2.386c-.345 0-.627-.285-.627-.629V8.108c0-.345.282-.63.63-.63h2.386c.346 0 .627.285.627.63 0 .349-.281.63-.63.63H17.61v1.125h1.755zm-3.855 3.016c0 .27-.174.51-.432.596-.064.021-.133.031-.199.031-.211 0-.391-.09-.51-.25l-2.443-3.317v2.94c0 .344-.279.629-.631.629-.346 0-.626-.285-.626-.629V8.108c0-.27.173-.51.43-.595.06-.023.136-.033.194-.033.195 0 .375.104.495.254l2.462 3.33V8.108c0-.345.282-.63.63-.63.345 0 .63.285.63.63v4.771zm-5.741 0c0 .344-.282.629-.631.629-.345 0-.627-.285-.627-.629V8.108c0-.345.282-.63.63-.63.346 0 .628.285.628.63v4.771zm-2.466.629H4.917c-.345 0-.63-.285-.63-.629V8.108c0-.345.285-.63.63-.63.348 0 .63.285.63.63v4.141h1.756c.348 0 .629.283.629.63 0 .344-.282.629-.629.629M24 10.314C24 4.943 18.615.572 12 .572S0 4.943 0 10.314c0 4.811 4.27 8.842 10.035 9.608.391.082.923.258 1.058.59.12.301.079.766.038 1.08l-.164 1.02c-.045.301-.24 1.186 1.049.645 1.291-.539 6.916-4.078 9.436-6.975C23.176 14.393 24 12.458 24 10.314"/>
</svg>
''';

const photoIconSvg =
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M19.365 9.863c.349 0 .63.285.63.631 0 .345-.281.63-.63.63H17.61v1.125h1.755c.349 0 .63.283.63.63 0 .344-.281.629-.63.629h-2.386c-.345 0-.627-.285-.627-.629V8.108c0-.345.282-.63.63-.63h2.386c.346 0 .627.285.627.63 0 .349-.281.63-.63.63H17.61v1.125h1.755zm-3.855 3.016c0 .27-.174.51-.432.596-.064.021-.133.031-.199.031-.211 0-.391-.09-.51-.25l-2.443-3.317v2.94c0 .344-.279.629-.631.629-.346 0-.626-.285-.626-.629V8.108c0-.27.173-.51.43-.595.06-.023.136-.033.194-.033.195 0 .375.104.495.254l2.462 3.33V8.108c0-.345.282-.63.63-.63.345 0 .63.285.63.63v4.771zm-5.741 0c0 .344-.282.629-.631.629-.345 0-.627-.285-.627-.629V8.108c0-.345.282-.63.63-.63.346 0 .628.285.628.63v4.771zm-2.466.629H4.917c-.345 0-.63-.285-.63-.629V8.108c0-.345.285-.63.63-.63.348 0 .63.285.63.63v4.141h1.756c.348 0 .629.283.629.63 0 .344-.282.629-.629.629M24 10.314C24 4.943 18.615.572 12 .572S0 4.943 0 10.314c0 4.811 4.27 8.842 10.035 9.608.391.082.923.258 1.058.59.12.301.079.766.038 1.08l-.164 1.02c-.045.301-.24 1.186 1.049.645 1.291-.539 6.916-4.078 9.436-6.975C23.176 14.393 24 12.458 24 10.314"/></svg>
    ''';

const restaurantIconSvg =
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M5 3H19C20.1046 3 21 3.89543 21 5V19C21 20.1046 20.1046 21 19 21H5C3.89543 21 3 20.1046 3 19V5C3 3.89543 3.89543 3 5 3ZM7 7V17H9V7H7ZM11 7V17H13V7H11ZM15 7V17H17V7H15Z" fill="#010F07"/>
</svg>
''';
const profileIconSvg =
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M8.66667 7.83333C8.66667 9.67428 10.1591 11.1667 12 11.1667C13.8409 11.1667 15.3333 9.67428 15.3333 7.83333C15.3333 5.99238 13.8409 4.5 12 4.5C10.1591 4.5 8.66667 5.99238 8.66667 7.83333ZM11.9861 12.8333C8.05159 12.8333 4.82355 14.8554 4.50054 18.8327C4.48295 19.0493 4.89726 19.5 5.10625 19.5H18.8722C19.4983 19.5 19.508 18.9962 19.4983 18.8333C19.2541 14.7443 15.976 12.8333 11.9861 12.8333Z" fill="#010F07"/>
</svg>
''';

const lockIconSvg =
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M17 10C18.1046 10 19 10.8954 19 12V18C19 19.1046 18.1046 20 17 20H7C5.89543 20 5 19.1046 5 18V12C5 10.8954 5.89543 10 7 10V9C7 6.23858 9.23858 4 12 4C14.7614 4 17 6.23858 17 9V10ZM12 6C10.3431 6 9 7.34315 9 9V10H15V9C15 7.34315 13.6569 6 12 6Z" fill="#010F07"/>
</svg>
''';
const photoFrameSvg =
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect x="3" y="3" width="18" height="18" rx="2" stroke="#010F07" stroke-width="2"/>
<circle cx="8" cy="8" r="2" fill="#010F07"/>
<path d="M21 17L16 12L10 18L3 11" stroke="#010F07" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

const cardIconSvg =
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M3.66669 7.83334C3.66669 6.91287 4.41288 6.16667 5.33335 6.16667H18.6667C19.5872 6.16667 20.3334 6.91286 20.3334 7.83334V8.66667H3.66669V7.83334ZM3.66669 11.1667H20.3334V16.1667C20.3334 17.0871 19.5872 17.8333 18.6667 17.8333H5.33335C4.41288 17.8333 3.66669 17.0871 3.66669 16.1667V11.1667ZM16.1667 13.6667C15.7065 13.6667 15.3334 14.0398 15.3334 14.5C15.3334 14.9602 15.7064 15.3333 16.1667 15.3333H17.8334C18.2936 15.3333 18.6667 14.9602 18.6667 14.5C18.6667 14.0398 18.2936 13.6667 17.8334 13.6667H16.1667Z" fill="#010F07"/>
</svg>
''';

const markerIconSvg =
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M6.16666 10.75C6.16666 7 8.66666 4.5 12.4167 4.5C16.1667 4.5 18.6667 7.625 18.6667 10.75C18.6667 12.6938 16.853 15.3631 13.2258 18.7577C12.7628 19.191 12.0487 19.209 11.5645 18.7996C7.96595 15.7565 6.16666 13.0733 6.16666 10.75ZM12.4167 12C13.5672 12 14.5 11.0673 14.5 9.91667C14.5 8.76607 13.5672 7.83333 12.4167 7.83333C11.2661 7.83333 10.3333 8.76607 10.3333 9.91667C10.3333 11.0673 11.2661 12 12.4167 12Z" fill="#010F07"/>
</svg>
''';

const fbIconSvg =
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<g opacity="0.64">
<path fill-rule="evenodd" clip-rule="evenodd" d="M13.1547 19V11.9992H15.2255L15.5 9.58665H13.1547L13.1582 8.37916C13.1582 7.74992 13.2223 7.41278 14.1907 7.41278H15.4853V5H13.4142C10.9264 5 10.0507 6.17033 10.0507 8.13848V9.58692H8.5V11.9994H10.0507V19H13.1547Z" fill="#010F07"/>
</g>
</svg>
''';

const shareIconSvg =
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M7.62683 13.6939C7.6272 13.7341 7.62753 13.7697 7.62753 13.8006C7.62753 13.9503 7.62676 14.1578 7.62596 14.3719C7.62512 14.5999 7.62424 14.8354 7.62424 15.0163H7.74443C7.97199 15.0163 8.17547 14.8667 8.25435 14.6414L8.25437 14.6414C8.92315 12.731 9.86818 11.5708 11.0894 11.1607C11.9413 10.8746 12.879 10.7862 14.1953 10.748V13.7028C14.1953 13.8474 14.247 13.9866 14.3401 14.0927C14.5441 14.3252 14.888 14.3392 15.1083 14.1238L19.8257 9.51233C19.8373 9.50103 19.8484 9.4892 19.859 9.47688C20.0607 9.24216 20.044 8.87926 19.8216 8.66632L15.1042 4.14884C15.0042 4.05306 14.874 4 14.7389 4C14.4387 4 14.1953 4.25691 14.1953 4.57383V7.54677C12.1221 7.64403 10.3885 7.85731 9.23015 9.08696C7.6001 10.8174 7.62014 12.9747 7.62683 13.6939ZM11.176 5.46295C11.176 5.04039 10.8515 4.69784 10.4511 4.69784H6.89939C5.2981 4.69784 4 6.06804 4 7.75827V16.9396C4 18.6298 5.2981 20 6.89939 20H15.5976C17.1989 20 18.497 18.6298 18.497 16.9396V15.4094C18.497 14.9868 18.1724 14.6442 17.7721 14.6442C17.3718 14.6442 17.0473 14.9868 17.0473 15.4094V16.9396C17.0473 17.7847 16.3982 18.4698 15.5976 18.4698H6.89939C6.09875 18.4698 5.4497 17.7847 5.4497 16.9396V7.75827C5.4497 6.91316 6.09875 6.22806 6.89939 6.22806H10.4511C10.8515 6.22806 11.176 5.88551 11.176 5.46295Z" fill="#010F07"/>
</svg>
''';
