fs            = require 'fs'
_             = require 'lodash'
transliterate = require 'transliterate'

###
  Config
###

## technology ##
exports.tech = tech = []

path = "#{__dirname}/../static/img/technology"
fs.readdirSync(path).forEach (technology)->
  if fs.statSync("#{path}/#{technology}").isFile()
    tech.push "/img/technology/#{technology}"

## phone ##
exports.phone = "+7 (495) 79-222-44"

## email ##
exports.email = "getstarted@makeomatic.ru"

## copyright ##
exports.copyright = "Makeomatic, (c) 2012-2013<br/>Разработка сайтов и мобильных приложений"

## address ##
exports.address = "Россия, Москва, Ленинский пр-т, д 1, офис 314<br/>индекс: 111555"


###
  Config -- homepage
###

## Title ##
exports.main_page_title = "Создание сайтов в Москве, разработка мобильных приложений, дизайн"
exports.team_page_title = "Cлаженная команда для разработки веб приложений и игр"


## Team ##
exports.employees = employees = [
  {
    photo: "/img/employee/002.png"
    name:  "Вячеслав Гусев"
    occupation: "Граф дизайнер"
    brief_description: "Профессиональный веб-дизайнер"
    description: "Кулинар компьютерного мира, у которого нет проблем с идеей и воплощением. Играет со шрифтами по 10 раз на дню, меняет цвета щелчком пальца и кликом мышки. Любит многослойные конструкции с вкусной, сочной начинкой. Те, кто пробовал его дизайн сайта, облизывают пальцы, а кто нет – кусают локти. Изготавливает изыски любой сложности и простоты, печет продающее оформление, украшает все гениальным юзабилити."
    rank: 4
    status: "То тут, то там"
  }
  {
    photo: "/img/employee/001.png"
    name:  "Виталий Аминев"
    occupation: "CEO"
    brief_description: "Мозговой центр и директор компании"
    description: "В первую очередь не босс, а лидер. Свободно говорит на Javascript. Читая коды, видит готовые веб-приложения. Вдохновляет коллег целеустремленностью и кофе-брейками. Опытом его работы можно три раза обернуть земной шар, а талантом загородить Солнце. Эффективно управляет компанией, видит нестандартные решения, упрощает сложные задачи и показывает чудеса профессионализма. 24 часа, 7 дней в неделю."
    rank: 10
    status: "Основатель компании"
  }
  {
    photo: "/img/employee/004.png"
    name:  "Анна Аминева"
    occupation: "Дир по развитию"
    background: "/img/employee/backgrounds/anna.png"
    brief_description: "Внимательно следите за глазами"
    description: "Как снайпер в засаде, она контролирует все. Цели покоряются одна за другой, не в силах сопротивляться ее точным и эффективным решениям. Всегда поможет клиенту-союзнику в борьбе за продвижение мобильных приложений. Быстро и без шума избавляется от проблем, устраняет возникшие препятствия. Строит далеко идущие планы на прочных фундаментах и каждый раз добивается лучшего результата."
    rank: 9
    status: "Искатель"
  }
  {
    photo: "/img/employee/005.png"
    name:  "Арман Манукян"
    occupation: "Креативный Арма"
    brief_description: "Генератор идей"
    description: "Работает на кофе и вкусной выпечке. Главное его оружие – уникальный интеллект. Способен решать задачи, выходящие за грань понимания большинства. Как и все гении, зачастую непонятен окружающим, но мы его все равно любим. Даже такое привычное дело, как разработка и продвижение сайтов, делает по-своему, необычно и удивительно. Заражает других своим креативом через общение."
    rank: 0
    status: "Кручу-верчу"
  }
  {
    photo: "/img/employee/006_dmitry.png"
    name:  "Дмитрий Шебалдин"
    occupation: "Секретное Оружие"
    brief_description: "Правительственный агент"
    description: "Молодой амбициозный разработчик и наше секретное оружие. Два года разрабатывал крупные информационные системы для государства, в результате набрался не только  огромного опыта, но и связей. Теперь решил заняться частной практикой. Находчив, как детектив, профессионален и немногословен. Изготовление сайтов под ключ для него – дело техники. Опыт сложной разработки у него иногда берут в долг. Но он не жадный и с удовольствием помогает коллегам решать ответственные задачи."
    rank: 5
    status: "Основная команда"
  }
  {
    photo: "/img/employee/007.png"
    name:  "Дмитрий Горбунов"
    occupation: "Mobile Guru"
    brief_description: "Обширные знания и классная смекалка"
    description: "Опытный разработчик приложений. Наш гуру, постигший все премудрости кодинга и достигший высшего просветления в области высоконагруженных систем. Постоянно медитирует для улучшения удобоваримости приложений, способен лишь силой мысли заставлять скрипты работать быстрее и лучше. С ним создание мобильных приложений всегда приводит к идеальному результату."
    rank: 8
    status: "Старший в команде"
  }
  {
    photo: "/img/employee/008.png"
    name:  "Алексей Князев"
    occupation: "Python-мастер"
    brief_description: "Заклинатель змей"
    description: "Виртуозный разработчик и заклинатель Python и C. Под движения его пальцев буквы кода выстраиваются в нужную последовательность, а сайты и программы начинают работать правильно и без багов. Укротит любую нерабочую схему, заставит сайт плясать под нужную дудку. Как заклинатель змей, он искусно играет с проблемами и всегда подбирает оптимальные решения."
    rank: 4
    status: "Старший подмастерье"
  }
  {
    photo: "/img/employee/009.png"
    name: "Владимир Горшунов"
    occupation: "Ученик"
    brief_description: "Веб-подмастерье"
    description: "Системное мышление - главное оружие Владимира. Хаос множества технологий структурируется как электроны вокруг атома. Сложнейшие проблемы он разбивает на неделимые частицы, досконально изучает их и встраивает готовый компонент в систему."
    rank: 2
    status: "Подмастерье"
  }
]

#generating ids
employees.forEach (employee)->
  employee.id = transliterate(employee.name.replace(/\s/g, "").toLowerCase())

## Portfolio ##
exports.portfolio = portfolio = []

## Рекорды рынка недвижимости ##
portfolio.push require('./fixtures/recordi')

## Фотобот ##
portfolio.push require('./fixtures/photobot')

## Brains App ##
portfolio.push require('./fixtures/brainsapp')

## Фабрика тепла ##
portfolio.push require('./fixtures/fabrika')

## speakgeo ##
portfolio.push require('./fixtures/speakgeo')

## openInclude ##
portfolio.push require('./fixtures/openinclude')

## LiveOne ##
portfolio.push require('./fixtures/liveone')

## ФитКафе ##
portfolio.push require('./fixtures/fitcafe')




## Links ##
push_empoyee_link = (employees) -> _.map employees, (employee) -> return {href: "##{employee.id}", name: employee.name}
push_portfolio_link = (portfolio) -> _.map portfolio, (project) -> return {href: "##{project.brand}", name: project.brand}

exports.links = [
  {name: "Блог",        href: "/blog", always: true }
  {name: "Команда",     href: "/team", children : push_empoyee_link(employees), isTeam: true, always: true }
  {name: "О нас",       href: "#about" }
  {name: "Портфолио",   href: "#portfolio", children: push_portfolio_link(portfolio), isMain: true }
  {name: "Технологии",  href: "#tech"}
  {name: "Контакты",    href: "#contacts", always: true}
]

exports.description = "Агентство Makeomatic с радостью воплотит в жизнь Ваши идеи! Создание сайтов в Москве, разработка мобильных приложений, дизайна, UX и игр являются нашей основной специализацией."
exports.team_description = "Команда Makeomatic включает в себя только лучших специалистов в своих областях. Мы работаем слаженно, знаем свои плюсы и минусы, работаем так, чтобы было приятно и клиентам, и нам."
