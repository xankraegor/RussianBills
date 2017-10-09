//
//  BillParser.swift
//  RussianBills
//
//  Created by Xan Kraegor on 18.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import Kanna

// Example from the new site
// http://sozd.parlament.gov.ru/bill/15455-7

final public class BillParser {

    var tree: [BillParserPhase] = []

    init?(withHTML html: HTMLDocument) {

        let phases = html.xpath("//div[contains(@class, 'child_etaps arrh_div')]")

        guard phases.count > 0 else {
            debugPrint("∆ BILL PARSER: Can't find any phases")
            return nil
        }

        var phaseStorage: BillParserPhase?
        var currentEvent: BillParserEvent?

        for phase in phases {

            let divs = phase.xpath("div")
            guard divs.count > 0 else { continue }

            for div in divs {

                // Phase header located: div class="oz_event bh_etap bh_etap_not"
                if let header = div.xpath("div[contains(@class, 'table_td')]").first {
                    guard let headerName = header.xpath("span[contains(@class, 'name')]").first?.content  else {
                        continue }

                    print("Type 1")

                    // Saving existing events and phase if any:

                    if phaseStorage != nil {
                        tree.append(phaseStorage!)
                    }

                    // Reinitializing storage
                    phaseStorage = BillParserPhase(withName: headerName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                                        print("Phase Header: \(phaseStorage!.name)")

                    // Event content block div class="oz_event bh_etap with_datatime"

                } else if let eventContentDateBlock = div.xpath("div[contains(@class, 'bh_etap_date')]").first  {

                    print("Type 2")

                    // General Event Description
                    // TODO: Remove Resolution Description from String
                    guard let eventName = div.content else {
                        continue
                    }

                    let trimmedName = eventName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).condenseWhitespace()
                    debugPrint("Event name: \(trimmedName)")
                    // Reinitializing current event
                    currentEvent = BillParserEvent(withName: eventName, date: nil)

                    // Date and time strings
                    if let eventDateString = eventContentDateBlock.xpath("span[contains(@class, 'mob_not')]").first?.content {
                        let date = eventDateString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        currentEvent?.date = date
                    }

                    if let eventTimeString = eventContentDateBlock.xpath("div[contains(@class, 'bh_etap_date_time')]").first?.content {
                        let time = eventTimeString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let fullDate = (currentEvent?.date ?? "") + " " + time
                        currentEvent?.date = fullDate
                    }

                    debugPrint("Datetime: \(currentEvent?.date ?? "")")

                    if let otherEventContent = div.xpath("div[contains(@class, 'algstname')]/div[contains(@class, 'table_td')]//li").first {

                        // Does it have attached resolutios?
                        if let detailedDescr = otherEventContent.xpath("span[contains(@class, 'pun_number pull-right')]").first {

                            // Attached resolution description
                            let resolutionDesc = detailedDescr.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "(указание отсутствует)"
                            currentEvent?.attachmentsNames.append("Решение, см. " + resolutionDesc)

                            // Attached resolution link
                            if let resolutionLink = detailedDescr.xpath("span/a").first?["href"] {
                                let resLink = resolutionLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                currentEvent?.attachments.append(resLink)
                            }
                        }
                    }

                    // Attachments
                    let attachments = div.xpath("div[contains(@class, 'event_files')]/span/a")
                    for attachment in attachments {
                        if let attLink = attachment["href"]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), let attName =
                            attachment.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                            currentEvent?.attachments.append(attLink)
                            currentEvent?.attachmentsNames.append(attName)
                        }
                    }

                    // Hidden attachments
                    let hiddenAttBlock = div.xpath("div[contains(@class, 'event_files')]/div[contains(@class, 'event_files')]/span/a")
                    for attachment in hiddenAttBlock {
                        if let attLink = attachment["href"]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), let attName =
                            attachment.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                            currentEvent?.attachments.append(attLink)
                            currentEvent?.attachmentsNames.append(attName)
                        }
                    }

                    if let count = currentEvent?.attachments.count, count > 0 {
                        for i in 0...count - 1 {
                            debugPrint("Attachment '\(currentEvent?.attachmentsNames[i] ?? "наименовение отсутствует")'; \(currentEvent?.attachments[i] ?? "ссылка отсутствует") ")
                        }
                    }


                    phaseStorage?.events.append(currentEvent!)
                }
            }
        }

        if phaseStorage != nil {
            tree.append(phaseStorage!)
            phaseStorage = nil
        }
    }

}
