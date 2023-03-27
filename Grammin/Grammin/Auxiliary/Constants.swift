//
//  Constants.swift
//  Grammin
//
//  Created by Ethan Hess on 5/31/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import Foundation

//MARK: References (Firebase Database Nodes)

let UsersReference = "Users"
let FollowingReference = "Following"
let PostsReference = "Posts"
let LikesReference = "Likes"
let StoriesReference = "Stories"
let StoryViewsReference = "StoryViews" //Who viewed what story (as opposed to posts etc.)
let ProfileReference = "Profile"

// Notifications

let viewTappedNotification = "viewTapped"
let updateFeedAfterPostingNotification = "updateFeed"

//MARK: --- OBJECT KEYS ---

//User object (TODO, add latitude/longitude for geotracking? Not at initial sign up but after)

let usernameKey = "username"
let emailKey = "email"
let fcmKey = "fcmToken"
let profileURLKey = "profileURL"

//Post object
let imageUrlKey = "imageUrl"
let postCaptionKey = "caption"
let imageWidthKey = "imageWidth"
let imageHeightKey = "imageHeight"
let createdAt = "creationDate"
let videoURLKey = "videoURL"
let mediaTypeKey = "mediaType"
let multipleKey = "multiple"
let mediaArrayKey = "mediaArray"

//Chat object
let mainChatsNode = "Chats" //Will store full chat object, Chats > UID
//let chatMatesNode = "ChatMates" //don't need anymore?
let messagesNode = "Messages"
let readMessages = "ReadMessages"
let unreadMessages = "UnreadMessages"

//Chat struct
let chatAuthorUIDKey = "chatAuthorUID"
let chatNameKey = "chatName"
let chatLastMessageKey = "chatLastMessage" //For display in Chat's VC
let chatParticipantsKey = "chatParticipants"

//Message
let messageAuthorUIDKey = "messageAuthorUID"
let messageImageURLKey = "messageImageURL"
let messageVideoURLKey = "messageVideoURL"
let messageMediaTypeKey = "messageMediaType"
let messageBodyTextKey = "messageBodyTextKey"
let messageMultipleKey = "messageMultipleMedia" //multiple images / videos
let messageTimestampKey = "messageTimestamp"

//Friend object

//Story object

let storyAuthorUIDKey = "storyAuthorUID"

//Seg

let segmentAuthorUIDKey = "segmentAuthorUID"

//Comment object

let commentCaptionKey = "commentCaption"
let commentAuthorUIDKey = "commentAuthorUID"

//Like
let likerUIDKey = "likerUID"
let likeeUIDKey = "likeeUID"

