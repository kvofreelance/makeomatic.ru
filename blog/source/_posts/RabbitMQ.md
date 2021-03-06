title: RabbitMQ: Простая и эффективная очередь сообщений.
subtitle: что такое RabbitMQ и его применение
date: 2013-10-16
author: Дмитрий Горбунов
gravatarMail: atskiisotona@gmail.com
tags: [RabbitMQ, очередь сообщений, Node.js]
---

В этой статье рассмотрим, как работает RabbitMQ, а также как и для чего её можно использовать в проектах на Node.js

## Очереди сообщений

Что такое очередь сообщений (`message queue`)? Это некая структура данных, которая обеспечивает хранение и передачу двоичных данных (`blobs`) между различными участниками системы. Очереди сообщений практически всегда используются в крупных системах, благодаря важным преимуществам.

- ***Независимость*** компонентов системы друг от друга. Благодаря использованию очереди, компоненты взаимодействуют через некий общий интерфейс, но ничего не знают о существовании друг друга.
- ***Экономия ресурсов*** достигается вследствие возможности разумно распределять информацию, поступающую в очередь от одних процессов, между другими процессами, осуществляющими её обработку. Кроме того, благодаря тому, что нет необходимости промежуточного хранения необработанных данных, достигается дополнительная экономия ресурсов.
- ***Надежность*** очередей достигается благодаря возможности накапливать сообщения, амортизируя недостаток вычислительных возможностей системы, а также благодаря независимости компонентов. Помимо этого очередь может аккомодировать сбои отдельных компонентов, осуществляя доставку «опоздавших» сообщений после восстановления.
- И, наконец, ***гарантия последовательной обработки***, позволяющая точно контролировать потоки данных в системе и запускать асинхронную обработку там, где это необходимо, не беспокоясь, что одна операция выполнится раньше другой, от результата которой она зависит.

Учитывая огромную важность очередей для надёжных и гибких систем обработки данных, была даже разработана спецификация протокола — AMQP, на основе которой разрабатывается несколько приложений, выполняющих функцию очереди — так называемых «**брокеров**». Аналогия с биржевыми процессами будет прослеживаться и в дальнейшем. Мы рассмотрим брокер RabbitMQ, авторами которого и создан протокол AMQP.
<!-- more -->

## Почему RabbitMQ?

Причин несколько, но одна из основных — реализация приложения на платформе Erlang/OTP, гарантирующая максимальную стабильность и масштабируемость очереди, как ключевого узла всей системы. Другая причина — полная открытость приложения, распространяющегося по лицензии Mozilla Public License и реализация открытого протокола AMQP, библиотеки для которого существуют во всех основных языках и платформах программирования. В том числе и для Node.js

## Основные понятия

### Брокер

Под брокером мы будем понимать сам сервер RabbitMQ. Брокер может быть один, брокеров может быть несколько, объединённых в общий кластер. Брокер занимается непосредственно передачей сообщений. Однако на внутреннем уровне происходит намного больше процессов, нежели просто передача байтиков по сети.

### Очередь

Очередь — основной логический компонент брокера. Именно из очереди клиент (`consumer`) забирает сообщения. Другое дело, что очередь не единственный участник обмена.

### Биржа

Биржа (**exchange**, иногда переводится как «обмен») играет важнейшую роль в направлении сообщений от отправителя (`producer`) к клиенту (*consumer*, он же потребитель). Дело в том, что именно благодаря бирже, поступающее от отправителя сообщение направляется в нужную очередь. Кроме того, у сообщения может присутствовать метка (`routingKey`) (ключ м
Это наиболее важная строчка, в которой мы сообщаем брокеру, что сообщение было принято, полностью обработано и его можно безопасно удалить из очереди. Если такое подтверждение брокеру не отправить, то сообщение никогда не будет удалено из очереди и постепенно брокер заполнит всю оперативную память сервера. Будьте внимательны — это одна из самых частых ошибок при работе с очередью.

**Важно**: отправляйте `ack` только когда сообщение *действительно* полностью обработано и его можно удалить. Это будет гарантировать две вещи:

- Не будет потерянных сообщений
- Очередь сможет распределять нагрузку максимально честно, т.к. пока от клиента не придёт подтверждение, что обработка завершена, новое сообщение ему отправлено не будет

**Важно**: если сообщение обработать невозможно по техническим или каким-то другим причинам у вас есть два варианта.

- Всё равно отправить `ack` и навсегда потерять сообщение
- Вызывать `channel.nack`, отказавшись принимать и обрабатывать сообщение, тогда очередь добавит сообщение в конец и со временем оно снова будет отправлено на обработку (возможно другому клиенту)

**Обратите внимание: брокер по-умолчанию сам распределяет нагрузку между клиентами, вам ничего не нужно для этого делать. Один у вас клиент, или пятьдесят — брокеру всё равно.**

### Publish-Subscribe (он же Broadcast)

Никто не запрещает отправлять сообщения *сразу всем* клиентам, а не по алгоритму round-robin. Это позволяет использовать очередь в качестве сервера pubsub. Всё, что для этого нужно сделать — определить биржу типа **fanout**. Делается это в вызове `assertExchange`:

```javascript
channel.assertExchange("incoming", "fanout")
```

Как видно, тип биржи передаётся вторым параметром. Поменяйте код отправителя и клиентов (помните, что определения бирж и очередей должны совпадать), как показано выше и попробуйте запустить несколько клиентов. Посмотрите, как будут распределяться сообщения теперь.

Всего одно маленькое дополнение — и совершенно изменившийся алгоритм работы. Как видите, для того, чтобы менять поведение брокера, вовсе не нужно лезть в глубокие настройки сервера. Достаточно слегка поменять код.

### Маршрутизация по шаблону

Как вы заметили, тип биржи определяет алгоритм работы брокера. Типом по-умолчанию является direct. Этот тип отправляет сообщения в чётком соответствии с `routingKey`, биржей и очередью. Тип `fanout` осуществляет доставку сообщений всем и сразу. А вот тип topic позволяет избирательно доставлять сообщения по шаблону, передаваемому всё в том же `routingKey`. Только формат этого параметра теперь становится особенным.

Метка должна содержать несколько слов, разделённых точкой. Например: «a.b» или «animals.feline.tiger». Должна присутствовать по крайней мере одна точка. Максимальный размер метки — 255 байт. Обратите внимание: не символов, байт. Если вы используете символы Unicode, то имейте это ввиду.

Существует два особых знака, которые используются в routingKey *при привязке очереди к бирже по метке* (и только тогда, но не при отправке!):

- «\*», обозначающая *ровно одно слово* (например: «animals.feline.*» — подойдёт к «animals.feline.tiger», но не к «animals.feline.leopard.panther»)
- «#», обозначающий *ноль или более слов* (например: «animals.#» — подойдёт и к «animals.feline» и к «animals.canine.wolf»)

Следующая привязка

```javascript
channel.bindQueue("messages", "incoming", "animals.feline.*")
```

Позволит нам принимать все сообщения о животных из семейства кошачьих, не имеющих подвидов.

Ну а следующее сообщение будет получено клиентом, который добавил вышестоящую привязку:

```javascript
channel.publish("incoming", "animals.feline.tiger", new Buffer("Rroarrrr!"))
```

Зато такое сообщение им принято не будет:

```javascript
channel.publish("incoming", "animals.feline.cat.domestic", new Buffer("Meow!"))
```

### Remote Procedure Call

Иногда возникает потребность передать сообщение обработчику ***И*** дождаться ответа. Этот сценарий описывает систему «удалённого вызова процедур». Такая система тоже вполне может быть построена с помощью RabbitMQ. Посмотрим, как это сделать.

#### Клиент

На клиенте всё очень просто: в вызов publish добавляется специальная опция replyTo, значением которой является имя очереди, в которой клиент будет ожидать ответ. Обратите внимание, что в данном случае клиент обращается к серверу именно через publish, поскольку он хочет вызвать удалённую процедуру, находящуюся на сервере. В данном сценарии отправителем будет являться клиент, а потребителем — сервер. Затем их роли поменяются местами, когда сервер отправит клиенту ответ.

```javascript
channel.publish("api", "calculate", new Buffer("2 + 3"), {replyTo: "api-reply", correlationId: "calculate-1"})
```

Подразумевается, что очередь "api-reply" существует. Однако здесь следует заметить вот что: поскольку клиент ожидает ответ на конкретный вызов, то очередь, в которую придёт ответ должна быть уникальна. Для этой ситуации предусмотрена опция `exclusive: true` в вызове `assertQueue` — она гарантирует, что данная очередь будет доступна исключительно вызывавшему `assertQueue` клиенту и видна только в пределах канала связи. Мы могли бы создавать такую эксклюзивную очередь для *каждого* отдельного вызова RPC. Но это было бы крайне неэффективно (зато очень просто в реализации). Более выгодным вариантом является создание одной очереди на клиента
маршрутизации), которая дополнительно повлияет на решение брокера о том, в какую очередь сообщение будет отправлено.

Обратите внимание: очередь вторична по отношению к бирже. Именно биржа определяет, куда пойдёт сообщение, в какую очередь. Клиенты же могут принимать сообщения только из очереди, поэтому если вы не хотите разбираться с кучей проблем и передать всю маршрутизацию сообщений брокеру — имейте следующее в виду: *если вы хотите отделить одни сообщения от других, их нужно разместить в разных очередях*.

Другими словами, сообщения в одной очереди должны быть одинаковы по структуре, чтобы вы могли корректно и без усилий распределять их по системе. Рассматривайте очередь как набор элементов одинакового типа.

## Варианты работы

### Прямая передача

В этом варианте в самом простом случае у нас один клиент и один отправитель. Отправитель шлёт сообщение в очередь, клиент слушает очередь, достаёт из неё сообщения и обрабатывает их. Рассмотрим как это работает на следующем примере.

```javascript
var rabbit = require("amqplib").connect()
rabbit.then(function(connection) {
	var ok = connection.createChannel()

	ok.then(function(channel) {
		// durable: true is set by default
		channel.assertQueue("messages")
		channel.assertExchange("incoming")
		channel.bindQueue("messages", "incoming", "mda")

		for (i = 0; i < 100; i++)
			channel.publish("incoming", "mda", new Buffer("Hello " + i), {deliveryMode: true})
	})

	return ok
}).then(null, console.log)
```

Для работы с RabbitMQ в Node.js лучше всего использовать библиотеку `amqplib`, реализующую соответствующий протокол. В этом случае вы можете использовать любой брокер, который соответствует этому протоколу.

Библиотека вносит ещё один элемент в работу с очередью: канал. Однако это не более чем просто канал связи между брокером и общающимся с ним компонентом системы. Не следует рассматривать его как часть брокера или очереди сообщений.

### Связь с брокером и создание канала

Рассмотрим по порядку, что происходит после установления связи с брокером и создания канала.

```javascript
channel.assertQueue("messages")
channel.assertExchange("incoming")
```

Два этих вызова обеспечивают существование очереди и биржи. Каждая очередь и биржа создаётся лишь один раз, а вызовы никак не влияют на уже существующие объекты. Очередь можно создать с дополнительными параметрами, важнейшим из которых является параметр `durable` — он влияет на то, будут ли сообщения в очереди сохранены в случае падения брокера. По-умолчанию в данной библиотеке этот параметр установлен в `true`. Подробнее обо всех параметрах создания очереди и биржи можно прочесть в документации к библиотеке. Отметим лишь, что в дальнейших примерах мы воспользуемся разными типами бирж.

```javascript
channel.bindQueue("messages", "incoming", "mda")
```

Этот вызов осуществляет привязку очереди к бирже и сообщению с конкретным `routingKey`: очередь messages привязывается к бирже `incoming`, которая должна передавать в эту очередь сообщения с меткой `mda`. Теперь мы можем либо принимать сообщения из этой очереди, будучи уверенными, что наш клиент через конкретный данный канал будет получать лишь сообщения с меткой `mda`, переданные через биржу `incoming`. Либо передавать сообщения в биржу incoming с меткой `mda`, зная, что они попадут в очередь `messages`. Если мы попытаемся передать сообщение с другой меткой, оно уйдёт в `/dev/null`, поскольку мы привязали лишь одну конкретную метку. Если мы попытаемся передать сообщение в несуществующую биржу, оно уйдёт в `/dev/null`, если привязать биржу к несуществующей очереди — тоже.

```javascript
channel.publish("incoming", "mda", new Buffer("Hello " + i), {deliveryMode: true})
```

Далее мы в цикле передаём сто сообщений бирже `incoming` с меткой `mda` (она же `routingKey`) и опцией `deliveryMode: true`, означающей что сообщение будет сохранено в очереди, если брокер выйдет из строя на время. Следует заметить, что сохранение сообщения на диск — операция медленная, и брокер может упасть в её процессе. Так что абсолютной надёжности эта опция не даёт.

Сто сообщений мы передаём для демонстрации масштабирования системы исключительно средствами брокера, что очень просто и безболезненно.

### Клиент для тестирования отправителя

Рассмотрим клиент, который нам нужен для тестирования отправителя. Запустим два или даже три таких клиента, после чего запустим отправителя, и убедимся, что все сообщения были распределены между клиентами максимально честно, по алгоритму round-robin.

```javascript
var rabbit = require("amqplib").connect()
rabbit.then(function(connection) {
	var ok = connection.createChannel()

	ok.then(function(channel) {
		// durable: true is set by default
		channel.assertQueue("messages")
		channel.assertExchange("incoming")
		channel.bindQueue("messages", "incoming", "mda")

		channel.consume("messages", function(message) {
			console.log(message.content.toString())

			channel.ack(message)
		})
	})

	return ok
}).then(null, console.log)
```

**Обратите внимание**: насколько код клиента похож на код отправителя. Отличается лишь то, что вместо отправки сообщений, мы принимаем их. Как было сказано выше, принимать сообщения можно лишь из очереди (так же как отправлять — только на биржу).

```javascript
channel.ack(message)
```

*Однако в этом случае возникает вопрос*: как отделить ответ на один вызов от другого? Для этой ситуации предназначен ещё один параметр вызова `publish`: `correlationId`. Он принимает строковое значение и возвращается в ответе от сервера, чтобы клиент мог на его основе определить, результат какого вызова он получил только что. Его можно генерировать случайным образом. Если же клиенту приходит ответ с неизвестным `correlationId`, то его можно смело игнорировать. Такое может случиться из-за рассинхронизации сервера и брокера, например, в случае падения сервера.

### Общий алгоритм работы

1. При запуске клиент создаёт эксклюзивную для себя очередь
2. Для каждого вызова клиент отправляет дополнительные параметры: `replyTo` и `correlationId`. Последний должен быть уникален для вызова.
3. Сервер слушает очередь, в которую отправляются вызовы от клиентов (обратите внимание, это *не* `replyTo`, а ещё одна отдельная очередь, общая для всех клиентов и сервера)
4. При поступлении запроса, сервер обрабатывает его и отправляет ответ в очередь `replyTo` вместе с `correlationId`, полученными от клиента в запросе
5. Клиент слушает очередь `replyTo`, при поступлении туда сообщения, он соотносит `correlationId` с имеющейся у него таблицей вызовов и обрабатывает результат

**Замечание**: если отправить сообщение через `publish` с пустым значением имени «биржи», а в качестве `routingKey` указать значение `replyTo`, то сообщение уйдёт по назначению:

```javascript
channel.publish("", request.properties.replyTo, new Buffer("5"), {correlationId: request.properties.correlationId})
```

Аналогично можно отправлять сообщения и с клиента в очередь `rpc`:

```javascript
channel.publish("", "rpc", new Buffer("2 + 3"), {replyTo: "rpc-reply-1", correlationId: "calculate-1"})
```
