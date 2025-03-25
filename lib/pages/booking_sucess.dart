import 'package:flutter/material.dart';
// TODO: add flutter_svg package to pubspec.yaml
import 'package:flutter_svg/flutter_svg.dart';

class UploadSuccessfulScreen extends StatelessWidget {
  const UploadSuccessfulScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SvgPicture.string(
                    uploadSuccessfulIllistration,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              ErrorInfo(
                title: "Booking Sucessful",
                description:
                    "Bookung has been successfully made. You can view the booking details in the app",
                // button: you can pass your custom button,
                btnText: "View more Resturaunts",
                press: () {
                  Navigator.pushNamed(context, '/homepage');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorInfo extends StatelessWidget {
  const ErrorInfo({
    super.key,
    required this.title,
    required this.description,
    this.button,
    this.btnText,
    required this.press,
  });

  final String title;
  final String description;
  final Widget? button;
  final String? btnText;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16 * 2.5),
            button ??
                ElevatedButton(
                  onPressed: press,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)))),
                  child: Text(btnText ?? "Retry".toUpperCase()),
                ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

const uploadSuccessfulIllistration =
    '''<svg width="1080" height="1080" viewBox="0 0 1080 1080" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M390 805C166.5 778.5 244.5 490.5 433.5 542.5C458.5 271.5 832.5 306.5 817.5 572.5C966.5 534.5 1041.5 759.5 863 803L390 805Z" fill="#DDDDDD"/>
<path d="M328.5 780C305.933 779.993 283.726 774.35 263.893 763.584C244.061 752.817 227.231 737.268 214.933 718.347C202.634 699.426 195.256 677.734 193.467 655.238C191.679 632.742 195.537 610.156 204.692 589.53C213.847 568.904 228.008 550.891 245.891 537.126C263.773 523.361 284.81 514.281 307.092 510.708C329.374 507.136 352.196 509.186 373.485 516.671C394.774 524.156 413.856 536.839 429 553.57" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M372.5 516.5C372.5 409.91 458.91 328.5 565.5 328.5C672.09 328.5 758.5 414.91 758.5 521.5C758.521 541.524 755.424 561.429 749.32 580.5" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M756.87 546.63C773.164 542.201 790.217 541.304 806.886 544.001C823.555 546.698 839.455 552.926 853.521 562.268C867.587 571.61 879.495 583.849 888.446 598.167C897.397 612.485 903.185 628.551 905.422 645.287C907.66 662.024 906.295 679.046 901.419 695.212C896.543 711.378 888.268 726.316 877.15 739.024C866.031 751.733 852.325 761.918 836.95 768.899C821.575 775.879 804.886 779.494 788 779.5" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M328.5 779.5H788.5" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M565.01 889.96C608.646 889.96 644.02 854.586 644.02 810.95C644.02 767.314 608.646 731.94 565.01 731.94C521.374 731.94 486 767.314 486 810.95C486 854.586 521.374 889.96 565.01 889.96Z" fill="#BCBCBC"/>
<path d="M566.72 889.69C610.356 889.69 645.73 854.316 645.73 810.68C645.73 767.044 610.356 731.67 566.72 731.67C523.084 731.67 487.71 767.044 487.71 810.68C487.71 854.316 523.084 889.69 566.72 889.69Z" stroke="#0E0E0E" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M566.74 850.17V789.7" stroke="#0E0E0E" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M547.59 808.09L566.24 782.27L585.6 808.09" stroke="#0E0E0E" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M470 651.5C494.577 651.5 514.5 631.577 514.5 607C514.5 582.423 494.577 562.5 470 562.5C445.423 562.5 425.5 582.423 425.5 607C425.5 631.577 445.423 651.5 470 651.5Z" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M470 640.5C488.502 640.5 503.5 625.502 503.5 607C503.5 588.498 488.502 573.5 470 573.5C451.498 573.5 436.5 588.498 436.5 607C436.5 625.502 451.498 640.5 470 640.5Z" fill="#0E0E0E"/>
<path d="M489 594C491.209 594 493 592.209 493 590C493 587.791 491.209 586 489 586C486.791 586 485 587.791 485 590C485 592.209 486.791 594 489 594Z" fill="white"/>
<path d="M482 603C483.105 603 484 602.105 484 601C484 599.895 483.105 599 482 599C480.895 599 480 599.895 480 601C480 602.105 480.895 603 482 603Z" fill="white"/>
<path d="M644 651.5C668.577 651.5 688.5 631.577 688.5 607C688.5 582.423 668.577 562.5 644 562.5C619.423 562.5 599.5 582.423 599.5 607C599.5 631.577 619.423 651.5 644 651.5Z" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M644 640.5C662.502 640.5 677.5 625.502 677.5 607C677.5 588.498 662.502 573.5 644 573.5C625.498 573.5 610.5 588.498 610.5 607C610.5 625.502 625.498 640.5 644 640.5Z" fill="#0E0E0E"/>
<path d="M663 594C665.209 594 667 592.209 667 590C667 587.791 665.209 586 663 586C660.791 586 659 587.791 659 590C659 592.209 660.791 594 663 594Z" fill="white"/>
<path d="M656 603C657.105 603 658 602.105 658 601C658 599.895 657.105 599 656 599C654.895 599 654 599.895 654 601C654 602.105 654.895 603 656 603Z" fill="white"/>
<path d="M519 690C547.64 708 577 708.6 607 690" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M272.46 475.5C316.643 475.5 352.46 439.683 352.46 395.5C352.46 351.317 316.643 315.5 272.46 315.5C228.277 315.5 192.46 351.317 192.46 395.5C192.46 439.683 228.277 475.5 272.46 475.5Z" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M235.62 395.57L265.84 424L309.29 367.5" stroke="#0E0E0E" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M810 209.5C821.874 209.5 831.5 199.874 831.5 188C831.5 176.126 821.874 166.5 810 166.5C798.126 166.5 788.5 176.126 788.5 188C788.5 199.874 798.126 209.5 810 209.5Z" fill="#BCBCBC"/>
<path d="M818 261C822.418 261 826 257.418 826 253C826 248.582 822.418 245 818 245C813.582 245 810 248.582 810 253C810 257.418 813.582 261 818 261Z" fill="#BCBCBC"/>
<path d="M746.5 238C757.27 238 766 229.27 766 218.5C766 207.73 757.27 199 746.5 199C735.73 199 727 207.73 727 218.5C727 229.27 735.73 238 746.5 238Z" fill="#BCBCBC"/>
<path d="M158 869C162.971 869 167 864.971 167 860C167 855.029 162.971 851 158 851C153.029 851 149 855.029 149 860C149 864.971 153.029 869 158 869Z" fill="#BCBCBC"/>
<path d="M228.5 895C238.165 895 246 887.165 246 877.5C246 867.835 238.165 860 228.5 860C218.835 860 211 867.835 211 877.5C211 887.165 218.835 895 228.5 895Z" fill="#BCBCBC"/>
<path d="M186 951C201.464 951 214 938.464 214 923C214 907.536 201.464 895 186 895C170.536 895 158 907.536 158 923C158 938.464 170.536 951 186 951Z" fill="#BCBCBC"/>
<path d="M788 141L766 119" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M818 139L826 109" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M843.5 149.5L856.5 144.5" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M214.5 855.5L204.5 838.5" stroke="#231F20" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M234.5 850.5L245.5 833.5" stroke="#231F20" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M177.5 336.5L118.5 315.5" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M235.5 297.5L206.85 208.37" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M319.5 303.5L343.5 250.5" stroke="#0E0E0E" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
