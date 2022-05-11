//
//  GoogleDataLoader.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import SwiftUI
import OAuth2


let GoogleOauth2 = OAuth2CodeGrant(settings: [
    "client_id": "294330188609-s5t4l16lrpmkpc73jmu4kd368gjqjgj7.apps.googleusercontent.com",
    "client_secret": "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",
    "authorize_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://www.googleapis.com/oauth2/v3/token",
    "scope": "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/calendar.events https://www.googleapis.com/auth/userinfo.email",
    "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob"],
] as OAuth2JSON)

