//
//  This file is part of the NineAnimator project.
//
//  Copyright © 2018-2020 Marcus Zhou. All rights reserved.
//
//  NineAnimator is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  NineAnimator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with NineAnimator.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import SwiftSoup

extension NASourceAnimeUnity {
    func anime(from link: AnimeLink) -> NineAnimatorPromise<Anime> {
        request(browseUrl: link.link).then {
            responseContent -> Anime in
            let bowl = try SwiftSoup.parse(responseContent)
            var animeTitle = try bowl.select(".content p").text()
            _ = try bowl.select("div.card-body p").compactMap {entry -> String in
                let trama = ""
                if (try entry.text().contains("TITOLO")){
                    let title = try entry.text()
                    animeTitle = String(title.dropFirst(8))
                }
                return trama
            }
            var x = 0
            let animeArtworkUrl = URL(
                string: try bowl.select(".cover>img").attr("src")
            ) ?? link.image
            let reconstructedAnimeLink = AnimeLink(
                title: animeTitle,
                link: link.link,
                image: animeArtworkUrl,
                source: self
            )
            
            // Obtain the list of episodes
            let episodes = try bowl.select("div.text-center div").reduce(into: [EpisodeLink]()) {
                collection, container in
                x += 1
                let episodeName = String(x)/*try container
                    .text()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
 */
                var episodeLink = try container.select("a").attr("href")
                print(episodeLink)
                episodeLink = episodeLink.replacingOccurrences(of: "'", with: "\'")
                print(episodeLink)
                print("-----------")
                if (!episodeLink.isEmpty){
                    print(episodeLink)
                    let newString = episodeLink.replacingOccurrences(of: "\'", with: "%27")
                    print("--")
                    print(newString)
                    episodeLink = "https://animeunity.it/" + newString
                collection.append(.init(
                    identifier: episodeLink,
                    name: episodeName,
                    server: NASourceAnimeUnity.FourAnimeStream,
                    parent: reconstructedAnimeLink
                ))
            }
            }
            
            // Information
            var animeSynopsis = ""
            _ = try bowl.select("div.card-body p").compactMap {entry -> String in
                let trama = ""
                if (try entry.text().contains("TRAMA")){
                    let trama = try entry.text()
                    animeSynopsis = String(trama.dropFirst(7))
//                     = try entry.text()
                }
                                if (try entry.text().contains("TITOLO")){
                                    let title = try entry.text()
                                    animeTitle = String(title.dropFirst(8))
                //                     = try entry.text()
                                }
                return trama
            }
//            animeSynopsis = anime.first ?? ""
            // Attributes
            var additionalAttributes = [Anime.AttributeKey: Any]()
            let detailContainers = try bowl.select("div.info div.detail")
            
            for container in detailContainers {
                _ = "ciao"//= try container.select(".title-side")
                let attributeName = ""//try attributeNameContainer.text()
//                try attributeNameContainer.remove()
                let attributeValue = try container
                    .text()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if attributeName.lowercased().contains("release date") {
                    additionalAttributes[.airDate] = attributeValue
                }
            }
            return Anime(
                reconstructedAnimeLink,
                
                alias: animeTitle,
                additionalAttributes: additionalAttributes,
                description: animeSynopsis,
                on: [ NASourceAnimeUnity.FourAnimeStream: "4anime" ],
                episodes: [ NASourceAnimeUnity.FourAnimeStream: episodes ],
                episodesAttributes: [:]
            )
        }
        
    }
    
}
