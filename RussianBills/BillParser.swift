//
//  BillParser.swift
//  RussianBills
//
//  Created by Xan Kraegor on 18.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import Kanna

// An example: the lanrgest existing page of this type to parse:
// http://asozd2.duma.gov.ru/main.nsf/(Spravka)?OpenAgent&RN=15455-7

final public class BillParser {

    var tree: [BillParserPhase] = []

    init?(withHTML html: HTMLDocument) {
        guard let body = html.body else {
            debugPrint("∆ BILL PARSER: Can't find the html body")
            return nil
        }

        guard let tab = body.xpath("//div[contains(@class, 'tab tab-act')]").first else {
            debugPrint("∆ BILL PARSER: Can't find the tab")
            return nil
        }

        let phases = tab.xpath("div[contains(@class, 'ata-block-doc data-block')]")

        guard phases.count > 0 else {
            debugPrint("∆ BILL PARSER: Can't find any phases")
            return nil
        }

        for phase in phases {
            guard let phaseHeader = phase.xpath("div[contains(@class, 'date-block-header')]").first
                else { continue }
            guard let phaseHeaderName = phaseHeader.content
                else { continue }
            
            var phaseStorage = BillParserPhase(withName: phaseHeaderName)
            let table = phase.xpath("table")[1]
            let events = table.xpath(".//tr")

            if events.count > 0 {
                var eventStorage: BillParserEvent?

                for event in events {
                    let fields = event.xpath("td")
                    if let linkObject = fields[0].xpath("a").first, eventStorage != nil  {
                        if let href = linkObject["href"] {
                            eventStorage?.attachments.append(href)
                            eventStorage?.attachmentsNames.append(linkObject.text ?? "")
                        }
                    } else if let name = fields[0].content {
                        let date = fields[1].content
                        let docNr = fields[2].content
                        if let lastEventExists = eventStorage {
                            phaseStorage.events.append(lastEventExists)
                        }
                        eventStorage = BillParserEvent(withName: name, date: date, docNr: docNr)
                    }
                }
                if let lastEventExists = eventStorage {
                    phaseStorage.events.append(lastEventExists)
                }
            } else {
                debugPrint("∆ BILL PARSER: Events count equals zero")
                return nil
            }

            tree.append(phaseStorage)
        }

    }


}

