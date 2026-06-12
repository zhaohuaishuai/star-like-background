import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/data/api/user.dart';
import 'package:m/data/module/active_member_params.dart';
import 'package:m/data/module/captcha_image.dart';
import 'package:m/data/module/login_params.dart';
import 'package:m/data/module/login_response.dart';
import 'package:m/data/module/register_params.dart';
import 'package:m/data/module/song.dart';
import 'package:m/data/module/user.dart';
import 'package:m/data/module/user_song.dart';
import 'package:m/features/pages/search/controller.dart';
import 'package:m/features/pages/search/index.dart';
import 'package:m/shared/widgets/button/cancel_button.dart';
import 'package:m/shared/widgets/button/primary_button.dart';
import 'package:m/shared/widgets/h1.dart';
import 'package:m/shared/widgets/login_dialog/index.dart';

class UserService extends GetxService {
  GetStorage box = GetStorage();
  UserProvider api = Get.put<UserProvider>(UserProvider());
  Rx<CaptchaImage?> captchaImage = Rx<CaptchaImage?>(null);
  final Rx<String?> _token = Rx<String?>(null);
  final Rx<User?> _user = Rx<User?>(null);
  User? get user => _user.value;
  bool get isLogin => _user.value != null;
  final Rx<List<UserSong>> _songList = Rx<List<UserSong>>([]);
  List<UserSong> get songList => _songList.value;
  final Rx<UserSong?> _shouCang = Rx<UserSong?>(null);
  get shouCangListen => _shouCang.listen;
  UserSong? get shouCang => _shouCang.value;

  /// 缓存设备指纹ID
  String? _cachedFingerprintId;
  Future<String> getFingerprintId() async {
    _cachedFingerprintId ??= await Utils.getOrCreateFingerprintId();
    return _cachedFingerprintId!;
  }

  /// 歌单列表中是否有未同步的指纹歌单（userId 为 null）
  Future<bool> hasFingerprintSongList() async {
    if (_songList.value.isEmpty) return false;
    return _songList.value.any((song) => song.userId == 0);
  }

  Future<UserService> init() async {
    return this;
  }

  @override
  void onInit() async {
    super.onInit();

    _token.listen((value) async {
      if (value is String) {
        await box.writeString(GetStorage.token, value);
      } else {
        await box.remove(GetStorage.token);
      }
    });

    await getInfo();
    // 无论是否登录都加载歌单（匿名用户通过 fingerprintId 获取）
    await getSongList();
  }

  static UserService get to => Get.find();

  Future<List<UserSong>> getSongList() async {
    List<UserSong> songList = await api.getSongList();
    _songList.value = songList;
    await getShouCang();
    return songList;
  }

  Future<void> logout() async {
    Get.defaultDialog(
      title: '退出登录'.tr,
      content: Text(
        '确定退出登录吗？'.tr,
        style: const TextStyle(fontSize: 18),
      ),
      actions: [
        CancelButton(),
      
        FilledButton(
          child: Text('确定'.tr, style: const TextStyle(color: Colors.white)),
          onPressed: () async {
            await api.logout();
            _token.value = null;
            box.remove(GetStorage.token);
            _user.value = null;
            _songList.value = [];
            _shouCang.value = null;
            Get.back();
          },
        ),
      ],
    );
  }

  Future<User?> getInfo() async {
    User? user = await api.getInfo();

    _user.value = user;
    return user;
  }

  Future<CaptchaImage?> getCaptchaImage() async {
    captchaImage.value = await api.captchaImage();

    return captchaImage.value;
  }

  Rx<bool> loginLoading = false.obs;
  Future<bool> login(LoginParams request) async {
    loginLoading.value = true;
    LoginResponse? response = await api.login(request);
    if (response?.token != null) {
      _token.value = response!.token!;
      await box.writeString(GetStorage.token, response.token!);
      await getInfo();
      await getSongList();
      await getShouCang();
      loginLoading.value = false;
      return true;
    } else {
      Utils.showToast(
        response?.msg ?? '登录失败'.tr,
        ToastStatusEnum.error,
      );
      loginLoading.value = false;
      return false;
    }
  }

  Future<bool> register(RegisterParams request) async {
    loginLoading.value = true;
    LoginResponse? response = await api.register(request);
    loginLoading.value = false;
    if (response.code == 200) {
      Utils.showToast(
        '注册成功，请激活账号'.tr,
        ToastStatusEnum.success,
      );
    } else {
      Utils.showToast(
        response.msg ?? '注册失败，请重试'.tr,
        ToastStatusEnum.error,
      );
    }
    return response.code == 200;
  }

  Future<bool> activeMember(ActiveMemberParams request) async {
    loginLoading.value = true;
    LoginResponse? response = await api.activeMember(request);
    loginLoading.value = false;
    if (response?.code == 200) {
      Utils.showToast(
        '激活成功'.tr,
        ToastStatusEnum.success,
      );
    } else {
      Utils.showToast(
        response?.msg ?? '激活失败，请重试'.tr,
        ToastStatusEnum.error,
      );
    }
    return response?.code == 200;
  }

  void showLoginDialog() {
    debugPrint('打开登录'.tr);
    Get.dialog(
      barrierDismissible: false,
      const LoginDialog(),
    );
  }

  addSongList([int? id, String? name = '']) async {
    Get.dialog(
        barrierDismissible: false,
        AddSongListDialog(
          id: id,
          name: name,
        ));
  }

  void delSongList(int id) async {
    Get.defaultDialog(
      title: '删除'.tr,
      content: Text(
        '确定要删除歌单吗？'.tr,
        style: const TextStyle(fontSize: 18),
      ),
      actions: [
        CancelButton(),
        
        FilledButton(
          child: Text('确定'.tr, style: const TextStyle(color: Colors.white)),
          onPressed: () async {
            bool success = await api.delSongList('$id');
            if (success) {
              await getSongList();
              Get.back();
            }
          },
        ),
      ],
    );
  }

  Future<bool> addSongListItemToSearch(int? id) async {
    try {
      Get.find<SearchPageController>();
    } catch (e) {
      Get.put<SearchPageController>(SearchPageController());
    }

    await Get.to(SearchPage(
      isPickeMode: true,
      onSelected: (songId) async {
        bool success = await api.addSongListItem('${id!}', songId);
        if (success) {
          Toast.showToast('添加成功'.tr);
        }
      },
    ));

    return true;
  }

  Future<bool> delSongListItemDIalog(int? id, String songId) async {
    Completer<bool> completer = Completer<bool>();
    Get.defaultDialog(
      title: '删除'.tr,
      content: Text(
        '确定要删除吗？'.tr,
        style: const TextStyle(fontSize: 18),
      ),
      actions: [
        CancelButton(),
        
        FilledButton(
          child: Text('确定'.tr, style: const TextStyle(color: Colors.white)),
          onPressed: () async {
            bool success = await api.delSongListItem('$id', songId);
            if (success) {
              if (!completer.isCompleted) {
                completer.complete(true);
              }
              Toast.showToast('删除成功'.tr);
              Get.back();
            } else {
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            }
          },
        ),
      ],
    );

    return completer.future;
  }

  Future<bool> updateSongList({required int id, String? name, String? list}) {
    return api.upSongList(id: '$id', name: name, list: list);
  }

  Future<bool> addSongListItem(int id, String songId) async {
    return await api.addSongListItem('$id', songId);
  }

  Future<bool> delSongListItem(int id, String songId) async {
    return await api.delSongListItem('$id', songId);
  }

  Future<UserSong?> getShouCang() async {
    UserSong? userSong = await api.getShouCang();
    _shouCang.value = userSong;
    return userSong;
  }

  /// 同步指纹歌单到登录账号
  Future<bool> syncFingerprintSongList() async {
    bool success = await api.syncSongList();
    if (success) {
      await getSongList();
      Utils.showToast('同步成功'.tr);
    } else {
      Utils.showToast('同步失败'.tr, ToastStatusEnum.error);
    }
    return success;
  }

  void showAddSongListBotomSheet({Song? song}) {
    Get.bottomSheet(BottomSheet(
        onClosing: () => {},
        builder: (BuildContext context) {
          return AddSongListBottomSheet(
            song: song,
          );
        }));
  }
}

class AddSongListBottomSheet extends StatefulWidget {
  final Song? song;
  final VoidCallback? onCancel;
  final VoidCallback? onSuccess;
  const AddSongListBottomSheet(
      {super.key, this.song, this.onCancel, this.onSuccess});

  @override
  State<AddSongListBottomSheet> createState() => _AddSongListBottomSheetState();
}

class _AddSongListBottomSheetState extends State<AddSongListBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: StarThemeData.bottomSheetHeight,
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                H1(title: '添加到歌单'.tr),
                const Padding(padding: EdgeInsets.only(left: 10)),
                const Icon(
                  Icons.playlist_add_check,
                  size: 32,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: UserService.to.songList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  trailing: TextButton.icon(
                    label: const Text('添加'),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      bool success = await UserService.to.addSongListItem(
                        UserService.to.songList[index].id,
                        widget.song!.id,
                      );
                      if (success) {
                        Toast.showToast('添加成功'.tr);
                      }
                    },
                  ),
                  title: Text(UserService.to.songList[index].name),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class AddSongListDialog extends StatefulWidget {
  final int? id;
  final String? name;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  const AddSongListDialog(
      {super.key, this.id, this.name, this.onSuccess, this.onCancel});

  @override
  State<AddSongListDialog> createState() => _AddSongListDialogState();
}

class _AddSongListDialogState extends State<AddSongListDialog> {
  late TextEditingController controller;
  UserProvider api = Get.put<UserProvider>(UserProvider());
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(Get.context!).size.width * 0.8,
        height: 230,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              '请输入歌单名称'.tr,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '请输入歌单名称'.tr,
                hintStyle: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CancelButton(
                  onPressed: () {
                    widget.onCancel?.call();
                    Get.back();
                  },
                ),
                PrimaryButton(
                  onPressed: () async {
                    String name = controller.text.trim();
                    if (name.isEmpty) {
                      Toast.showToast('歌单名称不能为空'.tr, ToastStatusEnum.error);
                      return;
                    }

                    bool success = false;
                    if (widget.id == null) {
                      success = await api.addSongList(name);
                    } else {
                      success =
                          await api.upSongList(id: '${widget.id!}', name: name);
                    }

                    if (success) {
                      widget.onSuccess?.call();
                      await UserService.to.getSongList();
                      Get.back();
                    }
                  },
                  text: '确认'.tr,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
