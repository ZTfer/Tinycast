// import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:tinycast/ui/page/up_next_queue/atom_widgets/queue_more_button.dart';

// 下拉菜单选项：
// 拷贝链接
// 收藏
// 分享
// 插播
// 标记为已播放
// 移除下载
// 从待播清单移除

class QueueEpisodeDropdown extends StatefulWidget {
  const QueueEpisodeDropdown({super.key});

  @override
  State<QueueEpisodeDropdown> createState() => _QueueEpisodeDropdownState();
}

class _QueueEpisodeDropdownState extends State<QueueEpisodeDropdown> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            customButton: const Icon(Icons.list, size: 46, color: Colors.red),
            items: [
              ..._MenuItems.firstItems.map(
                (item) => DropdownItem<_MenuItem>(
                  value: item,
                  height: 48,
                  child: _MenuItems.buildItem(item),
                ),
              ),
              const DropdownItem<Divider>(
                enabled: false,
                height: 8,
                child: Divider(),
              ),
              ..._MenuItems.secondItems.map(
                (item) => DropdownItem<_MenuItem>(
                  value: item,
                  height: 48,
                  child: _MenuItems.buildItem(item),
                ),
              ),
              const DropdownItem<Divider>(
                enabled: false,
                height: 8,
                child: Divider(),
              ),
              ..._MenuItems.thirdItems.map(
                (item) => DropdownItem<_MenuItem>(
                  value: item,
                  height: 48,
                  child: _MenuItems.buildItem(item),
                ),
              ),
            ],
            onChanged: (value) {
              _MenuItems.onChanged(context, value! as _MenuItem);
            },
            dropdownStyleData: DropdownStyleData(
              width: 160,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.redAccent,
              ),
              offset: const Offset(0, 8),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.only(left: 16, right: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({required this.text, required this.icon});

  final String text;
  final IconData icon;
}

abstract class _MenuItems {
  static const List<_MenuItem> firstItems = [copylink, favorite, share];
  static const List<_MenuItem> secondItems = [playNext, markAsPlayed];
  static const List<_MenuItem> thirdItems = [removeDownload, removeFromQueue];

  static const copylink = _MenuItem(text: '拷贝链接', icon: LucideIcons.copy);
  static const favorite = _MenuItem(text: '收藏', icon: LucideIcons.star);
  static const share = _MenuItem(text: '分享', icon: LucideIcons.share);
  static const playNext = _MenuItem(text: '插播', icon: LucideIcons.listStart);
  static const markAsPlayed = _MenuItem(
    text: '标记为已播放',
    icon: LucideIcons.check,
  );
  static const removeDownload = _MenuItem(
    text: '移除下载',
    icon: LucideIcons.trash,
  );
  static const removeFromQueue = _MenuItem(
    text: '从待播清单移除',
    icon: LucideIcons.x,
  );

  static Widget buildItem(_MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(item.text, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  static void onChanged(BuildContext context, _MenuItem item) {
    switch (item) {
      case _MenuItems.copylink:
        //Do something
        break;
      case _MenuItems.favorite:
        //Do something
        break;
      case _MenuItems.share:
        //Do something
        break;
      case _MenuItems.playNext:
        //Do something
        break;
      case _MenuItems.markAsPlayed:
        //Do something
        break;
      case _MenuItems.removeDownload:
        //Do something
        break;
      case _MenuItems.removeFromQueue:
        //Do something
        break;
    }
  }
}
