# Library Dropdown Menu Features - Verification Checklist

- [ ] Checkpoint 1: LibraryDropdown widget has all required parameters (onViewDetails, rssUrl, onCopyLinkSuccess, hasDownloadedEpisodes, onRemoveDownloads, onUnfollow)
- [ ] Checkpoint 2: "查看详情" menu item calls onViewDetails callback when clicked
- [ ] Checkpoint 3: "拷贝链接" menu item copies the RSS URL to clipboard when clicked
- [ ] Checkpoint 4: Success toast notification appears after copying link
- [ ] Checkpoint 5: "取消关注" menu item shows a confirmation dialog when clicked
- [ ] Checkpoint 6: Confirming unfollow deletes the podcast and its episodes from database
- [ ] Checkpoint 7: "移除下载" menu item is only visible when hasDownloadedEpisodes is true
- [ ] Checkpoint 8: "移除下载" menu item removes all downloaded episodes when clicked
- [ ] Checkpoint 9: Success toast notification appears after removing downloads
- [ ] Checkpoint 10: LibraryShowInfo correctly passes all required parameters to LibraryDropdown
- [ ] Checkpoint 11: All menu items close the dropdown after being clicked
- [ ] Checkpoint 12: Edge cases are handled (e.g., missing RSS URL)
- [ ] Checkpoint 13: UI feedback is consistent with existing app patterns
- [ ] Checkpoint 14: All functionality works on different screen sizes
