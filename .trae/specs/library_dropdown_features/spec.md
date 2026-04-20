# Library Dropdown Menu Features - Product Requirement Document

## Overview
- **Summary**: Implement comprehensive functionality for the library dropdown menu, including view details, copy link, unfollow, and remove downloads features.
- **Purpose**: Enhance user interaction with library items by providing intuitive right-click menu options for common actions.
- **Target Users**: Tinycast app users who manage their podcast library.

## Goals
- Implement "查看详情" (View Details) functionality to open podcast details page
- Implement "拷贝链接" (Copy Link) functionality to copy podcast RSS URL to clipboard
- Implement "取消关注" (Unfollow) functionality with confirmation dialog and database deletion
- Implement "移除下载" (Remove Downloads) functionality with conditional display and toast notification

## Non-Goals (Out of Scope)
- Adding new UI elements beyond the existing dropdown menu structure
- Modifying other parts of the library interface
- Implementing new database schemas or major data model changes

## Background & Context
- The library dropdown menu currently exists but has placeholder functionality
- The title click in `library_show_info.dart` already implements the details page navigation
- The episode dropdown menu already implements copy link functionality
- The app uses a database to store podcast and episode information

## Functional Requirements
- **FR-1**: View Details - When "查看详情" is clicked, navigate to the podcast details page
- **FR-2**: Copy Link - When "拷贝链接" is clicked, copy the podcast's RSS URL to clipboard
- **FR-3**: Unfollow - When "取消关注" is clicked, show a confirmation dialog, then delete the podcast and its episodes from database
- **FR-4**: Remove Downloads - When "移除下载" is clicked, remove all downloaded episodes for the podcast and show a toast notification
- **FR-5**: Conditional Display - Only show "移除下载" if the podcast has downloaded episodes

## Non-Functional Requirements
- **NFR-1**: User Experience - All menu actions should provide immediate feedback
- **NFR-2**: Error Handling - Handle edge cases like missing RSS URL or database errors
- **NFR-3**: Consistency - Follow existing UI patterns and code style

## Constraints
- **Technical**: Flutter framework, existing database structure, existing UI components
- **Dependencies**: Uses existing `Clipboard` API for copy functionality, existing database access methods

## Assumptions
- The podcast database contains an `rssUrl` field for each podcast
- The app has existing toast notification functionality
- The app has existing navigation methods for opening podcast details
- The app has existing methods for checking downloaded episodes

## Acceptance Criteria

### AC-1: View Details Functionality
- **Given**: User opens the library dropdown menu
- **When**: User clicks "查看详情"
- **Then**: The app navigates to the podcast details page
- **Verification**: `human-judgment`

### AC-2: Copy Link Functionality
- **Given**: User opens the library dropdown menu
- **When**: User clicks "拷贝链接"
- **Then**: The podcast's RSS URL is copied to clipboard
- **Verification**: `human-judgment`

### AC-3: Unfollow Functionality
- **Given**: User opens the library dropdown menu
- **When**: User clicks "取消关注"
- **Then**: A confirmation dialog appears
- **When**: User confirms the action
- **Then**: The podcast and its episodes are deleted from the database
- **Verification**: `human-judgment`

### AC-4: Remove Downloads Functionality
- **Given**: User has downloaded episodes for a podcast
- **When**: User opens the library dropdown menu
- **Then**: "移除下载" option is visible
- **When**: User clicks "移除下载"
- **Then**: All downloaded episodes for the podcast are removed
- **Then**: A toast notification confirms the action
- **Verification**: `human-judgment`

### AC-5: Conditional Display of Remove Downloads
- **Given**: User has no downloaded episodes for a podcast
- **When**: User opens the library dropdown menu
- **Then**: "移除下载" option is not visible
- **Verification**: `human-judgment`

## Open Questions
- [ ] What is the exact navigation method to open the podcast details page?
- [ ] What is the exact database access method for deleting podcasts and episodes?
- [ ] What is the exact method for checking downloaded episodes?
- [ ] What is the exact method for showing toast notifications?
