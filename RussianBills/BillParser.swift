//
//  BillParser.swift
//  RussianBills
//
//  Created by Xan Kraegor on 18.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import Kanna
import Crashlytics

// Example from the new site
// http://sozd.parlament.gov.ru/bill/15455-7

final public class BillParser {

    var tree = BillParserContent()

    init?(withHTML html: HTMLDocument) {

        let phases = html.xpath("//div[contains(@class, 'child_etaps arrh_div')]")

        guard phases.count > 0 else {
            assertionFailure("∆ BILL PARSER: Can't find any phases")
            let title = html.xpath("//title").first?.text ?? "no title"
            let err = NSError(.mainAppl, code: .parserError,
                              message: "Bill parser returns with failure: can't find phases in the provided html",
                              info: ["htmlTitle": title])
            Crashlytics.sharedInstance().recordError(err)
            return nil
        }

        var phaseStorage: BillParserPhase?
        var currentEvent: BillParserEvent?

        for phase in phases {

            let divs = phase.xpath("div")
            guard divs.count > 0 else {
                assertionFailure("∆ BILL PARSER: Can't find any events in a phase")
                let err = NSError(.mainAppl, code: .parserError,
                                  message: "Bill parser continues with failure: can't find events in phase",
                                  info: ["phaseContents": phase.content?.prettify(noQuotes: true) ?? ""])
                Crashlytics.sharedInstance().recordError(err)
                continue
            }

            for div in divs {

                // Phase header located: div class="oz_event bh_etap bh_etap_not"
                if let header = div.xpath("div[contains(@class, 'table_td')]").first {

                    guard let headerName = header.xpath("span[contains(@class, 'name')]").first?.content else {
                        assertionFailure("∆ BILL PARSER: Can't find event header. Event will not be displayed")
                        let err = NSError(.mainAppl, code: .parserError,
                                          message: "Bill parser continues with failure: can't find headerName in div",
                                          info: ["divContents": div.content?.prettify(noQuotes: true) ?? ""])
                        Crashlytics.sharedInstance().recordError(err)
                        continue
                    }

                    // Saving existing events and phase if any:

                    if let phaseStr = phaseStorage {
                        tree.phases.append(phaseStr)
                    }

                    // Reinitializing storage
                    phaseStorage = BillParserPhase(withName: headerName.prettify())

                    // Event content block div class="oz_event bh_etap with_datatime"

                } else if let eventContentDateBlock = div.xpath("div[contains(@class, 'bh_etap_date')]").first {

                    // General Event Description

                    guard let eventNameBox = div.xpath("div[contains(@class, 'algstname')]//span[contains(@class, 'name')]").first else {
                        continue
                    }

                    let eventName: String

                    if let eventNumberBox = eventNameBox.xpath(".//span[contains(@class, 'pun_number')]").first {
                        let documentNumberText = eventNumberBox.text?.prettify() ?? ""
                        let nameText = eventNameBox.text ?? ""
                        eventName = nameText.replacingOccurrences(of: documentNumberText, with: "").prettify() + "\n[\(documentNumberText)]"
                    } else {
                        eventName = eventNameBox.text?.prettify() ?? ""
                    }

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

                    if let otherEventContent = div.xpath("div[contains(@class, 'algstname')]/div[contains(@class, 'table_td')]//li").first {

                        // Does it have attached resolutions?
                        if let detailedDescr = otherEventContent.xpath("span[contains(@class, 'pun_number pull-right')]").first {

                            // Attached resolution description
                            let resolutionDesc = detailedDescr.text?.prettify() ?? "(указание отсутствует)"
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

                    phaseStorage?.events.append(currentEvent!)
                } else {
                    assertionFailure("∆ Bill parser: div could not be parsed")
                    let err = NSError(.mainAppl, code: .parserError,
                                      message: "Bill parser continues with failure: can't interpret a div",
                                      info: ["divContents": div.content?.prettify(noQuotes: true) ?? ""])
                    Crashlytics.sharedInstance().recordError(err)
                }
            }
        }

        if let phaseStr = phaseStorage {
            tree.phases.append(phaseStr)
            phaseStorage = nil
        }
    }

}
