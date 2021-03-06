//
//  TempRegSubjInfo.swift
//  RussianBills
//
//  Created by Xan Kraegor on 17.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

let regionalSubjectsData: Dictionary<Int, [String: String]> =
        [
            9755800: ["name": "Алтайское краевое Законодательное Собрание", "address": "Барнаул, ул. Анатолия, 81", "website": "http://www.akzs.ru"],
            6212500: ["name": "Архангельское областное Собрание депутатов", "address": "Архангельск, площадь Ленина, 1", "website": "http://aosd.ru/"],
            6212700: ["name": "Белгородская областная Дума", "address": "Белгород, Соборная площадь, 4", "website": "http://belduma.ru/"],
            6212800: ["name": "Брянская областная Дума", "address": "Брянск, площадь Карла Маркса, 2", "website": "http://www.dumabryansk.ru/"],
            6211500: ["name": "Верховный Совет Республики Хакасия", "address": "Ленина просп., 67, Абакан, Респ. Хакасия, 655017", "website": "http://www.vskhakasia.ru/"],
            10609900: ["name": "Верховный Хурал (парламент) Республики Тыва", "address": "Кызыл, улица Ленина, 32", "website": "http://khural.org/"],
            6213000: ["name": "Волгоградская областная Дума", "address": "Волгоград, проспект имени В.И. Ленина, 9", "website": "http://volgoduma.ru/"],
            6213200: ["name": "Воронежская областная Дума", "address": "Воронеж, улица Кирова, 2", "website": "http://www.vrnoblduma.ru/"],
            6210800: ["name": "Государственное Собрание (Ил Тумэн) Республики Саха (Якутия)", "address": "Якутск, улица Ярославского, 24/1", "website": "http://iltumen.ru/"],
            9883500: ["name": "Государственное Собрание - Курултай Республики Башкортостан", "address": "Уфа, улица Заки Валиди, 46", "website": "http://www.gsrb.ru/ru/"],
            6210600: ["name": "Государственное Собрание Республики Марий Эл", "address": "Йошкар-Ола, Ленинский проспект, 29", "website": "http://parlament.mari.ru/"],
            6210700: ["name": "Государственное Собрание Республики Мордовия", "address": "Саранск, Советская ул., 26", "website": "http://www.gsrm.ru/"],
            6209400: ["name": "Государственное Собрание - Эл Курултай Республики Алтай", "address": "Горно-Алтайск, улица Эркемена Палкина, 1", "website": "http://elkurultay.ru/"],
            6210500: ["name": "Государственный Совет Республики Коми", "address": "Сыктывкар, Коммунистическая улица, 8", "website": "http://gsrk.ru/"],
            11627600: ["name": "Государственный Совет Республики Крым", "address": "Симферополь, улица Карла Маркса, 18", "website": "http://crimea.gov.ru/"],
            6211200: ["name": "Государственный Совет Республики Татарстан", "address": "Казань, площадь Свободы, 1", "website": "http://www.gossov.tatarstan.ru/"],
            6211400: ["name": "Государственный Совет Удмуртской Республики", "address": "Ижевск, площадь имени 50-летия Октября, 15", "website": "http://www.udmgossovet.ru/"],
            6208900: ["name": "Государственный Совет - Хасэ Республики Адыгея", "address": "Майкоп, ул. Жуковского, 22", "website": "http://gshra.ru/"],
            8495100: ["name": "Государственный Совет Чувашской Республики", "address": "Чебоксары, Президентский бульвар, 10", "website": "http://gov.cap.ru/?gov_id=83"],
            10610800: ["name": "Дума Астраханской области", "address": "Астрахань, улица Володарского, 15", "website": "http://astroblduma.ru/"],
            10562700: ["name": "Дума Ставропольского края", "address": "Ставрополь, площадь Ленина, 1", "website": "http://www.dumask.ru/"],
            8549900: ["name": "Дума Ханты-Мансийского автономного округа - Югры", "address": "Ханты-Мансийск, улица Мира, 5", "website": "http://www.dumahmao.ru/"],
            6218400: ["name": "Дума Чукотского автономного округа", "address": "Анадырь, улица Отке, 29", "website": "http://duma.chukotka.ru/"],
            10610500: ["name": "Законодательная Дума Томской области", "address": "Томск, площадь Ленина, 6", "website": "https://duma.tomsk.ru/"],
            6212300: ["name": "Законодательная Дума Хабаровского края", "address": "Хабаровск, улица Муравьева-Амурского, 19", "website": "http://www.duma.khv.ru/"],
            9735600: ["name": "Законодательное Собрание Амурской области", "address": "Благовещенск, улица Ленина, 135", "website": "http://www.zsamur.ru/"],
            6212900: ["name": "Законодательное Собрание Владимирской области", "address": "Владимир, Октябрьский просп., 21", "website": "http://www.zsvo.ru/"],
            6213100: ["name": "Законодательное Собрание Вологодской области", "address": "Вологда, Пушкинская улица, 25", "website": "http://www.vologdazso.ru/"],
            11669600: ["name": "Законодательное Собрание города Севастополя", "address": "Севастополь, улица Ленина, 3", "website": "https://sevzakon.ru/"],
            6217600: ["name": "Законодательное Собрание Еврейской автономной области", "address": "Биробиджан, проспект 60-летия СССР, 18", "website": "http://zseao.ru/"],
            9884700: ["name": "Законодательное Собрание Забайкальского края", "address": "Чита, улица Чайковского, 8", "website": "http://www.zaksobr-chita.ru/"],
            9884400: ["name": "Законодательное Собрание Иркутской области", "address": "Иркутск, улица Ленина, 1А", "website": "http://www.irk.gov.ru/"],
            6213600: ["name": "Законодательное Собрание Калужской области", "address": "Калуга, площадь Старый Торг, 2", "website": "http://www.zskaluga.ru/"],
            9736200: ["name": "Законодательное Собрание Камчатского края", "address": "Петропавловск-Камчатский, пл. Ленина, 1", "website": "http://zaksobr.kamchatka.ru/"],
            8494000: ["name": "Законодательное Собрание Кировской области", "address": "Киров, улица Карла Либкнехта, 69", "website": "http://www.zsko.ru/"],
            6211900: ["name": "Законодательное Собрание Краснодарского края", "address": "Краснодар, ул. Красная, 3", "website": "http://www.kubzsk.ru/"],
            6212000: ["name": "Законодательное Собрание Красноярского края", "address": "Красноярск, проспект Мира, 110", "website": "http://www.sobranie.info/"],
            6214300: ["name": "Законодательное Собрание Ленинградской области", "address": "Санкт-Петербург, Суворовский просп., 67", "website": "http://www.lenoblzaks.ru/"],
            6214800: ["name": "Законодательное Собрание Нижегородской области", "address": "Нижний Новгород, Кремль, 2", "website": "http://www.zsno.ru/"],
            10610200: ["name": "Законодательное Собрание Новосибирской области", "address": "Новосибирск, улица Кирова, 3", "website": "http://zsnso.ru/"],
            6215100: ["name": "Законодательное Собрание Омской области", "address": "Омск, Красный Путь улица, 1", "website": "http://www.omsk-parlament.ru/"],
            6215200: ["name": "Законодательное Собрание Оренбургской области", "address": "Оренбург, улица 9 Января, 62", "website": "http://www.zaksob.ru/"],
            6215400: ["name": "Законодательное Собрание Пензенской области", "address": "Пенза, улица Кирова, 13", "website": "http://www.zspo.ru/"],
            9735900: ["name": "Законодательное Собрание Пермского края", "address": "Пермь, улица Ленина, 51", "website": "http://zsperm.ru/"],
            6974800: ["name": "Законодательное Собрание Приморского края", "address": "Владивосток, ул. Светланская, 22", "website": "http://www.zspk.gov.ru/"],
            6210200: ["name": "Законодательное Собрание Республики Карелия", "address": "Петрозаводск, ул. Куйбышева, 5", "website": "http://karelia-zs.ru/"],
            6215700: ["name": "Законодательное Собрание Ростовской области", "address": "Ростов-на-Дону, Социалистическая улица, 112", "website": "http://zsro.ru/"],
            8597500: ["name": "Законодательное Собрание Санкт-Петербурга", "address": "Санкт-Петербург, Вознесенский просп., 14", "website": "http://www.assembly.spb.ru/"],
            6216200: ["name": "Законодательное Собрание Свердловской области", "address": "Екатеринбург, ул. Бориса Ельцина, 10", "website": "http://zsso.ru/"],
            6216700: ["name": "Законодательное Собрание Тверской области", "address": "Тверь, Советская улица, 33", "website": "http://www.zsto.ru/"],
            6217100: ["name": "Законодательное Собрание Ульяновской области", "address": "Ульяновск, улица Радищева, 1", "website": "http://www.zsuo.ru/"],
            9508100: ["name": "Законодательное Собрание Челябинской области", "address": "Челябинск, ул. Кирова, 114/56", "website": "https://zs74.ru/"],
            10372700: ["name": "Законодательное Собрание Ямало-Ненецкого автономного округа", "address": "Салехард, улица Республики, 72", "website": "http://zsyanao.ru/"],
            9507200: ["name": "Ивановская областная Дума", "address": "Иваново, улица Батурина, 5А", "website": "http://www.ivoblduma.ru/"],
            6213500: ["name": "Калининградская областная Дума", "address": "Калининград, улица Кирова, 17", "website": "http://duma39.ru/duma/"],
            6214000: ["name": "Костромская областная Дума", "address": "Кострома, Советская площадь, 2", "website": "http://www.kosoblduma.ru/"],
            6214100: ["name": "Курганская областная Дума", "address": "Курган, ул. Гоголя, 56", "website": "http://www.kurganoblduma.ru/"],
            6214200: ["name": "Курская областная Дума", "address": "Курск, улица Софьи Перовской, 24", "website": "http://kurskduma.ru/"],
            6214400: ["name": "Липецкий областной Совет депутатов", "address": "Липецк, Ленина-Соборная площадь, 1", "website": "http://www.oblsovet.ru/"],
            6214500: ["name": "Магаданская областная Дума", "address": "Магадан, улица Горького, 8А", "website": "http://www.magoblduma.ru/"],
            6217500: ["name": "Московская городская Дума", "address": "Москва, Страстной бульвар, 15/29с1", "website": "https://duma.mos.ru/ru/"],
            6214600: ["name": "Московская областная Дума", "address": "Москва, Проспект Мира, 72", "website": "http://www.mosoblduma.ru/"],
            6214700: ["name": "Мурманская областная Дума", "address": "Мурманск, ул. Софьи Перовской, 2", "website": "http://duma-murman.ru/"],
            9400500: ["name": "Народное Собрание (Парламент) Карачаево-Черкесской Республики", "address": "Черкесск, улица Красноармейская, 54", "website": "http://parlament09.ru/"],
            6209500: ["name": "Народное Собрание Республики Дагестан", "address": "Махачкала, площадь Ленина, 1", "website": "http://www.nsrd.ru/"],
            9400200: ["name": "Народное Собрание Республики Ингушетия", "address": "Магас, проспект Вязикова, 16", "website": "http://www.parlamentri.ru/"],
            6210000: ["name": "Народный Хурал (Парламент) Республики Калмыкия", "address": "Элиста, улица Пушкина, 18", "website": "http://www.huralrk.ru/"],
            6209300: ["name": "Народный Хурал Республики Бурятия", "address": "Улан-Удэ, улица Сухэ-Батора, 9", "website": "http://www.hural-buryatia.ru/"],
            6214900: ["name": "Новгородская областная Дума", "address": "Великий Новгород, площадь Победы-Софийская, 1", "website": "http://duma.novreg.ru/"],
            6215300: ["name": "Орловский областной Совет народных депутатов", "address": "Орёл, площадь Ленина, 1", "website": "http://oreloblsovet.ru/"],
            6209700: ["name": "Парламент Кабардино-Балкарской Республики", "address": "Нальчик, Проспект Ленина, 55", "website": "http://parlament.kbr.ru/"],
            6211100: ["name": "Парламент Республики Северная Осетия-Алания", "address": "Владикавказ, площадь Свободы, 1", "website": "http://parliament-osetia.ru/"],
            9405700: ["name": "Парламент Чеченской Республики", "address": "Грозный, улица Восточная, 48", "website": "http://www.parlamentchr.ru/"],
            6215600: ["name": "Псковское областное Собрание депутатов", "address": "Псков, улица Некрасова, 23", "website": "http://sobranie.pskov.ru/"],
            6215800: ["name": "Рязанская областная Дума", "address": "Рязань, Почтовая улица, 50/57", "website": "http://rznoblduma.ru/"],
            6215900: ["name": "Самарская Губернская Дума", "address": "Самара, Молодогвардейская ул., 187", "website": "http://samgd.ru/~portal/"],
            6216000: ["name": "Саратовская областная Дума", "address": "Саратов, улица имени А.Н. Радищева, 24А", "website": "http://www.srd.ru/"],
            6216100: ["name": "Сахалинская областная Дума", "address": "Южно-Сахалинск, улица Чехова, 37", "website": "http://www.dumasakhalin.ru/"],
            6216500: ["name": "Смоленская областная Дума", "address": "Смоленск, площадь Ленина, 1", "website": "http://www.smoloblduma.ru/"],
            6218000: ["name": "Собрание депутатов Ненецкого автономного округа", "address": "Нарьян-Мар, улица Смидовича, 20", "website": "http://www.sdnao.ru/"],
            6213700: ["name": "Совет народных депутатов Камчатской области", "address": "Петропавловск-Камчатский, пл.Ленина, 1", "website": "http://zaksobr.kamchatka.ru/history/"],
            6213800: ["name": "Совет народных депутатов Кемеровской области", "address": "Кемерово, Советский просп., 58", "website": "http://www.sndko.ru/"],
            6216600: ["name": "Тамбовская областная Дума", "address": "Тамбов, улица Карла Маркса, 143/22", "website": "http://www.tambovoblduma.ru/"],
            6216900: ["name": "Тульская областная Дума", "address": "Тула, проспект Ленина, 2", "website": "http://www.tulaoblduma.ru/"],
            6217000: ["name": "Тюменская областная Дума", "address": "Тюмень, улица Республики, 52", "website": "http://www.duma72.ru/ru/"],
            9876700: ["name": "Ярославская областная Дума", "address": "Ярославль, Советская площадь, 1/19", "website": "http://www.duma.yar.ru/"]
        ]
