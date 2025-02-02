//
//  UserDefaultClient+Keys.swift
//
//  Created by ErrorErrorError on 12/22/22.
//
//

import Foundation
import SharedModels

extension UserDefaultsClient.Key {
    public static var hasShownOnboarding: UserDefaultsClient.Key<Bool> { .init("hasShownOnboarding") }
    public static var compactEpisodes: UserDefaultsClient.Key<Bool> { .init("compactEpisodes") }
    public static var videoPlayerAudioIsDub: UserDefaultsClient.Key<Bool> { .init("videoPlayerAudioIsDub") }

    public static var videoPlayerProvider: UserDefaultsClient.Key<String> { .init("videoPlayerProvider", defaultValue: "") }
    public static var videoPlayerSubtitle: UserDefaultsClient.Key<String> { .init("videoPlayerSubtitle", defaultValue: "") }
    public static var videoPlayerQuality: UserDefaultsClient.Key<Source.Quality?> { .init("videoPlayerQuality", defaultValue: nil) }
    public static var searchedItems: UserDefaultsClient.Key<[String]> { .init("searchedItems", defaultValue: []) }

    public static var hasClearedAllVideos: UserDefaultsClient.Key<Bool> { .init("hasClearedAllVideos") }

    public static var canEnableDiscord: UserDefaultsClient.Key<Bool> { .init("canEnableDiscord") }
}
