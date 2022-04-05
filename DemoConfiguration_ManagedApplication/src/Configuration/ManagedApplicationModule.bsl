////////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕННЫЕ МОДУЛЯ 
//

Перем ДрайверСканераШтрихкодов Экспорт; // Сканер штрихкодов
Перем ИдентификаторФоновогоЗадания Экспорт;

Процедура ПриНачалеРаботыСистемы()

#Если НЕ МобильныйКлиент Тогда 
	Параметры = СервисныеМеханизмы.ПолучитьПараметры();
	УстановитьКраткийЗаголовокПриложения(Параметры.КраткийЗаголовок);
	
	РаботаСПанельюЗадач.ДобавитьКнопки(Параметры.ПараметрыПанелиЗадачОС);
	
	БотКлиент.ПриНачалеРаботыСистемы();
#КонецЕсли

#Если МобильныйКлиент Тогда 
	Если ОсновнойСерверДоступен() = Истина Тогда
		ОбменМобильныеАвтономныйКлиент.НачатьОбмен();
	КонецЕсли;
	ПодключитьОбработчикОжидания("ПроверкаНеобходимостиСинхронизации", 3);
	
	// идентификатор подписчика надо получать регулярно, он может измениться
	УведомленияКлиент.ОбновитьИдентификаторПодписчикаУведомлений();
	
	// Подключение обработчика push-уведомлений
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаУведомлений", УведомленияКлиент);
	ДоставляемыеУведомления.ПодключитьОбработчикУведомлений(ОписаниеОповещения);
	
	// Подключение обработчика геозон
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаУведомлений", ГеопозиционированиеКлиент);
	СредстваГеопозиционирования.ПодключитьОбработчикПересеченияГраницОтслеживаемыхГеозон(ОписаниеОповещения);
	
#КонецЕсли

	ГлобальныйПоискКлиент.УстановитьОписаниеГлобальногоПоиска();
	
КонецПроцедуры

Процедура ПриГлобальномПоиске(СтрокаПоиска, ПланГлобальногоПоиска)
	
	СтрокаДолг = НСтр("ru = 'долг '", "ru");
	СтрокаДолги = НСтр("ru = 'долги'", "ru");
	МаксДлинаКодаВДокументах = 9;
	МинРазмерСтрокиДляПоискаКонтрагента = 2;
	ПорядокПоиска = 5;
	ПорядокПоискаКонтрагента = 1;
	
	Если СтрокаПоиска = "+" Тогда
		
		ПланГлобальногоПоиска.Очистить();
		ПланГлобальногоПоиска.Добавить("ГлобальныйПоискКомандыСоздать", "ГлобальныйПоискКлиент", Ложь);
		Возврат;
	КонецЕсли;
	
	Если СтрДлина(СтрокаПоиска) >= МинРазмерСтрокиДляПоискаКонтрагента Тогда
		
		ПланГлобальногоПоиска.Добавить("ГлобальныйПоискПоискКонтрагента", "ГлобальныйПоискСервер", Истина, Истина, ПорядокПоискаКонтрагента);
		
	КонецЕсли;
	
	Если НРег(СтрокаПоиска) = СтрокаДолги ИЛИ
		 (СтрДлина(СтрокаПоиска) > СтрДлина(СтрокаДолг) И Лев(НРег(СтрокаПоиска), СтрДлина(СтрокаДолг)) = СтрокаДолг)
	Тогда
		
		ПланГлобальногоПоиска.Добавить("ГлобальныйПоискПоказатьДолги", "ГлобальныйПоискСервер", Истина, Истина, ПорядокПоиска);
		
	ИначеЕсли СтрДлина(СтрокаПоиска) <= МаксДлинаКодаВДокументах Тогда
			
		ПланГлобальногоПоиска.Добавить("ГлобальныйПоискПоКоду", "ГлобальныйПоискСервер", Истина, Истина, ПорядокПоиска);
			
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриВыбореРезультатаГлобальногоПоиска(ЭлементРезультатаПоиска, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ТипЗнч(ЭлементРезультатаПоиска.Значение) = Тип("Структура") Тогда
		
		Если ЭлементРезультатаПоиска.Значение.Операция = "Взаиморасчеты" Тогда
			
			Отбор = Новый Структура;
			Отбор.Вставить("Контрагент", ЭлементРезультатаПоиска.Значение.Контрагент);
			Отбор.Вставить("Валюта", ЭлементРезультатаПоиска.Значение.Валюта);
			
			ПараметрыФормы = Новый Структура;
			ПараметрыФормы.Вставить("Отбор", Отбор);
			
			ОткрытьФорму("РегистрНакопления.Взаиморасчеты.ФормаСписка", ПараметрыФормы, , Истина);
			
		КонецЕсли;
		
	ИначеЕсли ЭлементРезультатаПоиска.Значение = "+Заказ" Тогда
		
		ОткрытьФорму("Документ.Заказ.ФормаОбъекта");
		
	ИначеЕсли ЭлементРезультатаПоиска.Значение = "+Приход" Тогда
		
		ОткрытьФорму("Документ.ПриходТовара.ФормаОбъекта");
		
	ИначеЕсли ЭлементРезультатаПоиска.Значение = "+Расход" Тогда
		
		ОткрытьФорму("Документ.РасходТовара.ФормаОбъекта");
		
	ИначеЕсли ЭлементРезультатаПоиска.Значение = "+Оплата" Тогда
		
		ОткрытьФорму("Документ.Оплата.ФормаОбъекта");
		
	Иначе
		
		СтандартнаяОбработка = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриВыбореДействияРезультатаГлобальногоПоиска(ЭлементРезультата, Действие)
	
	Если Действие = "Заказ" Тогда
		
		ЗначенияЗаполнения = Новый Структура("Покупатель", ЭлементРезультата.Значение);
		Параметры = Новый Структура("ЗначенияЗаполнения", ЗначенияЗаполнения);

		ОткрытьФорму("Документ.Заказ.ФормаОбъекта", Параметры);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриИзмененииДоступностиОсновногоСервера(НачалоСеансаОсновногоСервера)
#Если МобильныйКлиент Тогда 
	Если ОсновнойСерверДоступен() = Истина Тогда
		ОбменМобильныеАвтономныйКлиент.НачатьОбмен();
	КонецЕсли;
#КонецЕсли
КонецПроцедуры

#Если МобильныйКлиент Тогда 
Процедура НаблюдениеЗаСинхронизацией() Экспорт
	
	ТекстОшибки = "";
	Если ОбменМобильныеАвтономныйСервер.ОбменДаннымиЗакончен(ИдентификаторФоновогоЗадания, ТекстОшибки) Тогда
		ОтключитьОбработчикОжидания("НаблюдениеЗаСинхронизацией");
		Если  ТекстОшибки <> "" Тогда
		    Сообщение = Новый СообщениеПользователю();
		    Сообщение.Текст = ТекстОшибки;
			Сообщение.Сообщить();
		Иначе
			Если ОсновнойСерверДоступен() = Истина Тогда
				ОбменМобильныеКлиент.ОповеститьОЗавершении();
			КонецЕсли
		КонецЕсли
	КонецЕсли
	
КонецПроцедуры
#КонецЕсли

// Процедура осуществляет проверку на необходимость обмена данными с заданным интервалом
Процедура ПроверкаНеобходимостиСинхронизации() Экспорт
	
#Если МобильныйКлиент Тогда 
	Если ОсновнойСерверДоступен() = Истина Тогда
		ОбменМобильныеАвтономныйКлиент.НачатьОбмен();
	КонецЕсли;
#КонецЕсли


КонецПроцедуры

Процедура ОбработкаОтображенияОшибки(ИнформацияОбОшибке, ТребуетсяЗавершениеСеанса, СтандартнаяОбработка)
	
#Если НЕ МобильныйКлиент Тогда
	Если ОбработкаОшибок.КатегорияОшибкиДляПользователя(ИнформацияОбОшибке) = КатегорияОшибки.НарушениеПравДоступа Тогда
		СтандартнаяОбработка = Ложь;
				
		ДополнительныйТекст = НСтр("ru = 'Для решения проблемы позвоните Иванову Ивану, по телефону %(1)'");
		ПараметрТелефон = "%(1)";
		Индекс = СтрНайти(ДополнительныйТекст, "%(1)") - 1;
		ТекстДо = Лев(ДополнительныйТекст, Индекс);
		ТекстПосле = Прав(ДополнительныйТекст, СтрДлина(ДополнительныйТекст) - Индекс - СтрДлина(ПараметрТелефон));

		НомерТелефона = "+77777777777";
		ДополнительнаяИнформация = Новый ФорматированнаяСтрока(
			ТекстДо,
			Новый ФорматированнаяСтрока(НомерТелефона, Новый Шрифт(,, Истина)),
			ТекстПосле
		);
			
		ОбработкаОшибок.ПоказатьИнформациюОбОшибке(ИнформацияОбОшибке,, ДополнительнаяИнформация);
	КонецЕсли;
#КонецЕсли

КонецПроцедуры

Процедура ПриВыбореДействияСообщенияСистемыВзаимодействия(Сообщение, Действие)
	
	БотКлиент.ОбработкаДействияСообщения(Сообщение, Действие);

КонецПроцедуры
