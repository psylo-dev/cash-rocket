import 'package:cash_rocket/Model/scratch_card_model.dart';
import 'package:cash_rocket/generated/l10n.dart' as lang;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scratcher/widgets.dart';

import '../../Provider/profile_provider.dart';
import '../../Repositories/authentication_repo.dart';
import '../Constant Data/constant.dart';

class UseScratchCard extends StatefulWidget {
  const UseScratchCard({super.key, required this.scratchCardModel, required this.reward});

  final Data scratchCardModel;
  final int reward;

  @override
  State<UseScratchCard> createState() => _UseScratchCardState();
}

class _UseScratchCardState extends State<UseScratchCard> {
  bool isBalanceShow = false;
  final scratchKey = GlobalKey<ScratcherState>();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, ref, watch) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          titleSpacing: 0,
          toolbarHeight: 90,
          iconTheme: const IconThemeData(color: Colors.white),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
            ),
          ),
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: containerGradiant, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
          ),
          title: Text(
            lang.S.of(context).scratchCard,
            style: kTextStyle.copyWith(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Scratcher(
                  key: scratchKey,
                  brushSize: 30,
                  threshold: 50,
                  color: Colors.grey.shade400,
                  image: Image.asset('images/a1.png', fit: BoxFit.cover),
                  // onChange: (value) => print("Scratch progress: $value%"),
                  onThreshold: () async {
                    scratchKey.currentState!.reveal();
                    if (widget.reward > 0) {
                      try {
                        //EasyLoading.show(status: "Getting reward");
                        EasyLoading.show(status: lang.S.of(context).gettingReward);
                        bool status = await AuthRepo().scratchReward(widget.scratchCardModel.title ?? "Scratch Reward", widget.reward);
                        if (status) {
                          ref.refresh(personalProfileProvider);
                          ref.refresh(scratchCardProvider);
                          // EasyLoading.showSuccess("Rewarded Successfully");
                          EasyLoading.showSuccess(lang.S.of(context).rewardedSuccessfully);
                          Navigator.pop(context);
                        } else {
                          //EasyLoading.showError("Error Occurred");
                          EasyLoading.showError(lang.S.of(context).errorOccurred);
                        }
                      } catch (e, stackTrace) {
                        // EasyLoading.showError(e.toString());
                        print("Error in scratch card: $e");
                        print("Stack trace: $stackTrace");
                        EasyLoading.showError(e.toString());
                      }
                    } else {
                      EasyLoading.showInfo("Better luck next time");
                    }
                  },
                  child: Container(
                    height: 238,
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang.S.of(context).youHaveEarned,
                          style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kGreyTextColor, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${widget.reward} ${lang.S.of(context).coins}',
                          style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kGreyTextColor, fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lang.S.of(context).scratchTheAboveCardBySwipingOnnIt,
                style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kWhite),
              )
            ],
          ),
        ),
      );
    });
  }
}
