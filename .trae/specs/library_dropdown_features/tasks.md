# Library Dropdown Menu Features - The Implementation Plan (Decomposed and Prioritized Task List)

## [ ] Task 1: Update LibraryDropdown widget to accept necessary parameters
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - Add parameters to LibraryDropdown widget for podcast data, callbacks, and state
  - Add parameters for onViewDetails, rssUrl, onCopyLinkSuccess, hasDownloadedEpisodes, onRemoveDownloads, onUnfollow
- **Acceptance Criteria Addressed**: All
- **Test Requirements**:
  - `human-judgment` TR-1.1: Widget parameters are correctly defined and documented
- **Notes**: This is the foundation for all other functionality

## [ ] Task 2: Implement View Details functionality
- **Priority**: P0
- **Depends On**: Task 1
- **Description**:
  - Update the "查看详情" DropdownItem to call the onViewDetails callback
  - Pass the onViewDetails callback from LibraryShowInfo to LibraryDropdown
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `human-judgment` TR-2.1: Clicking "查看详情" opens the podcast details page
- **Notes**: Use the same navigation method as the title click in LibraryShowInfo

## [ ] Task 3: Implement Copy Link functionality
- **Priority**: P0
- **Depends On**: Task 1
- **Description**:
  - Add _handleCopyLink method to LibraryDropdown
  - Update the "拷贝链接" DropdownItem to call this method
  - Implement clipboard copy functionality using Clipboard API
  - Show success toast notification
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `human-judgment` TR-3.1: Clicking "拷贝链接" copies the RSS URL to clipboard
  - `human-judgment` TR-3.2: Success toast notification appears after copying
- **Notes**: Reference the implementation in EpisodeDropdown

## [ ] Task 4: Implement Unfollow functionality
- **Priority**: P0
- **Depends On**: Task 1
- **Description**:
  - Add _handleUnfollow method to LibraryDropdown
  - Update the "取消关注" DropdownItem to call this method
  - Implement confirmation dialog using showDialog
  - Call onUnfollow callback when confirmed
- **Acceptance Criteria Addressed**: AC-3
- **Test Requirements**:
  - `human-judgment` TR-4.1: Clicking "取消关注" shows a confirmation dialog
  - `human-judgment` TR-4.2: Confirming the action deletes the podcast from database
- **Notes**: The onUnfollow callback should handle the actual database deletion

## [ ] Task 5: Implement Remove Downloads functionality
- **Priority**: P0
- **Depends On**: Task 1
- **Description**:
  - Add conditional rendering for "移除下载" DropdownItem based on hasDownloadedEpisodes
  - Add _handleRemoveDownloads method to LibraryDropdown
  - Update the "移除下载" DropdownItem to call this method
  - Call onRemoveDownloads callback and show success toast
- **Acceptance Criteria Addressed**: AC-4, AC-5
- **Test Requirements**:
  - `human-judgment` TR-5.1: "移除下载" is only visible when hasDownloadedEpisodes is true
  - `human-judgment` TR-5.2: Clicking "移除下载" removes all downloaded episodes
  - `human-judgment` TR-5.3: Success toast notification appears after removal
- **Notes**: The onRemoveDownloads callback should handle the actual removal

## [ ] Task 6: Update LibraryShowInfo to pass necessary parameters
- **Priority**: P1
- **Depends On**: Task 1
- **Description**:
  - Add necessary parameters to LibraryShowInfo widget
  - Pass these parameters to LibraryDropdown when creating it
- **Acceptance Criteria Addressed**: All
- **Test Requirements**:
  - `human-judgment` TR-6.1: LibraryShowInfo correctly passes all required parameters to LibraryDropdown
- **Notes**: Ensure all callbacks are properly connected

## [ ] Task 7: Test all functionality
- **Priority**: P1
- **Depends On**: Tasks 2-6
- **Description**:
  - Test View Details functionality
  - Test Copy Link functionality
  - Test Unfollow functionality
  - Test Remove Downloads functionality
  - Test conditional display of Remove Downloads
- **Acceptance Criteria Addressed**: All
- **Test Requirements**:
  - `human-judgment` TR-7.1: All menu items work correctly
  - `human-judgment` TR-7.2: UI feedback is appropriate
  - `human-judgment` TR-7.3: Edge cases are handled
- **Notes**: Test with both downloaded and non-downloaded episodes
