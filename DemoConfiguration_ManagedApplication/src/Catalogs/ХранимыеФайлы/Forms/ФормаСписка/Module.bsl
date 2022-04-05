&НаКлиенте
Перем ТекущиеПомещаемыеФайлы;

//////////////////////////////////////////////////////////////////////////////// 
// ПРОЦЕДУРЫ И ФУНКЦИИ 
// 

// Функция извлекает из отбора формы списка значение элемента "владелец"
// 
// Возвращаемое значение: 
// СправочникСсылка.Товары, либо Неопределено, если владелец не найден
&НаКлиенте
Функция ПолучитьЗначениеВладельца()
	
	Для каждого Элемент из Список.Отбор.Элементы Цикл
		
		Если ТипЗнч(Элемент) =  Тип("ЭлементОтбораКомпоновкиДанных")
			 И (Строка(Элемент.ЛевоеЗначение) = "Владелец"
				ИЛИ Строка(Элемент.ЛевоеЗначение) = "Owner")
			 И Элемент.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно Тогда
			 
			Возврат Элемент.ПравоеЗначение;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

// Процедура получает список файлов, которые переданы на сервер и создает соответствующие элементы справочника
&НаСервере
Процедура СоздатьЭлементыСправочника(ДанныеЗагруженныхФайлов, Владелец)
	
	Для каждого ЗагруженныйФайл Из ДанныеЗагруженныхФайлов Цикл
		
		Файл = Новый Файл(ЗагруженныйФайл.ПолноеИмяФайла);
		ХранимыйФайл = Справочники.ХранимыеФайлы.СоздатьЭлемент();
		ХранимыйФайл.Владелец = Владелец;
		ХранимыйФайл.Наименование = Файл.Имя;
		ХранимыйФайл.ИмяФайла = Файл.Имя;
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(ЗагруженныйФайл.АдресВХранилище);
		ХранимыйФайл.ДанныеФайла = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных());
		ХранимыйФайл.Записать();
		
	КонецЦикла;
	
КонецПроцедуры

// Функция формирует массив описаний передаваемых файлов по выделенным строкам списка
&НаКлиенте
Функция ОписаниеВыделенныхФайлов()
	
	ПередаваемыеФайлы = Новый Массив;
	Для каждого Строка Из Элементы.Список.ВыделенныеСтроки Цикл
		
		ДанныеСтроки = Элементы.Список.ДанныеСтроки(Строка);
		Ссылка = ПолучитьНавигационнуюСсылку(Строка, "ДанныеФайла");
		ПутьКфайлу = ДанныеСтроки.Код + "\" + ДанныеСтроки.ИмяФайла;
		Описание = Новый ОписаниеПередаваемогоФайла(ПутьКфайлу, Ссылка);
		ПередаваемыеФайлы.Добавить(Описание);
		
	КонецЦикла;
	
	Возврат ПередаваемыеФайлы;
	
КонецФункции

//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ 
// 

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ТекущиеПомещаемыеФайлы = Новый Соответствие();
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////// 
// Обработчики команд
//

&НаКлиенте
Процедура ЗагрузитьФайлы()
	ВыполнитьЗагрузитьФайлы();
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьЗагрузитьФайлы()
	РезультатПодключенияРасширенияРаботыСФайлами = Ждать ПодключитьРасширениеРаботыСФайламиАсинх();
	Если РезультатПодключенияРасширенияРаботыСФайлами Тогда
		Форма = ПолучитьФорму("Справочник.ХранимыеФайлы.Форма.ФормаЗагрузкиФайлов");
		Форма.Владелец = ПолучитьЗначениеВладельца();
		Форма.ОписаниеОповещенияОЗакрытии =
			Новый ОписаниеОповещения("ЗагрузитьФайлыЗавершение", ЭтотОбъект);
		Форма.Открыть();
	Иначе
		ДопПараметры = Новый Структура (); 
		ДопПараметры.Вставить("Владелец", ПолучитьЗначениеВладельца());				
		ПослеПомещенияФайлов = Новый ОписаниеОповещения("ПослеПомещенияФайлов", ЭтотОбъект, ДопПараметры, "ПриОшибкеПомещения", ЭтотОбъект);
		ОХодеПомещенияФайлов = Новый ОписаниеОповещения("ХодПомещенияФайлов", ЭтотОбъект, ДопПараметры);
		ПередПомещенияФайлов = Новый ОписаниеОповещения("ПередПомещениемФайлов", ЭтотОбъект, ДопПараметры);
		ПараметрыДиалога = Новый ПараметрыДиалогаПомещенияФайлов("Файлы продукта");
		Попытка
			ПомещенныеФайлы = Ждать ПоместитьФайлыНаСерверАсинх(ОХодеПомещенияФайлов, ПередПомещенияФайлов, ПараметрыДиалога, УникальныйИдентификатор);
		Исключение
			Ждать ПредупреждениеАсинх(НСтр("ru='Ошибка помещения файлов'", "ru"));
			Возврат;
		КонецПопытки;
		Если ПомещенныеФайлы = Неопределено Или ПомещенныеФайлы.Количество() = 0 Тогда
			Возврат;
		КонецЕсли; 	
		Файлы = Новый Массив();	
		Для Каждого Файл из ПомещенныеФайлы Цикл
			ТекущиеПомещаемыеФайлы.Удалить(Файл.СсылкаНаФайл.ИдентификаторФайла);
			Если Не Файл.ПомещениеФайлаОтменено Тогда
			  	ПереданныйФайл = Новый Структура;
			  	ПереданныйФайл.Вставить("Имя", Файл.СсылкаНаФайл.Имя);
			  	ПереданныйФайл.Вставить("Адрес", Файл.Адрес);		  
			  	Файлы.Добавить(ПереданныйФайл);
			КонецЕсли;
		КонецЦикла; 	
		Если ТекущиеПомещаемыеФайлы.Количество() = 0 Тогда
			ПоказатьЗавершениеЗагрузки();
		КонецЕсли;
		Попытка
			ПослеПомещенияФайловНаСервере(Файлы, ДопПараметры);
			Элементы.Список.Обновить();	
		Исключение
			ОбработкаОшибок.ПоказатьИнформациюОбОшибке(ИнформацияОбОшибке());
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьФайлыЗавершение(Результат, Параметры) Экспорт
	Если Не Результат = Неопределено Тогда
		
		ЗагруженныеФайлы = Новый Массив();
		
		Для Каждого ЗагруженныйФайл Из Результат.СписокЗагруженныхФайлов Цикл
			ДанныеФайла = Новый Структура("ПолноеИмяФайла, АдресВХранилище", ЗагруженныйФайл.Значение.СсылкаНаФайл.Имя, ЗагруженныйФайл.Значение.Адрес);
			ЗагруженныеФайлы.Добавить(ДанныеФайла);
		КонецЦикла;
		
		СоздатьЭлементыСправочника(ЗагруженныеФайлы, Результат.Владелец);
		Элементы.Список.Обновить();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФайл()
	ПередаваемыеФайлы = ОписаниеВыделенныхФайлов();
	Если ПередаваемыеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	ВыполнитьОткрытьФайл(ПередаваемыеФайлы);
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьОткрытьФайл(ПередаваемыеФайлы)
	РезультатПодключенияРасширенияРаботыСФайлами = Ждать ПодключитьРасширениеРаботыСФайламиАсинх();
	Если РезультатПодключенияРасширенияРаботыСФайлами Тогда
		#Если НЕ МобильныйКлиент Тогда
		ИмяВыбранногоКаталога = РаботаСХранилищемОбщихНастроек.ПолучитьРабочийКаталог();
		Если ИмяВыбранногоКаталога = Неопределено Или ИмяВыбранногоКаталога = "" Тогда
			Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
			Диалог.Заголовок = НСтр("ru = 'Выбор каталога временного хранения файлов'", "ru");
			МассивИменВыбранныхКаталогов = Ждать Диалог.ВыбратьАсинх();
			Если МассивИменВыбранныхКаталогов = Неопределено Или Не МассивИменВыбранныхКаталогов.Количество() Тогда
				Возврат;
			КонецЕсли;
			ИмяВыбранногоКаталога = МассивИменВыбранныхКаталогов[0];
		КонецЕсли;
		#Иначе
		ИмяВыбранногоКаталога = Ждать КаталогВременныхФайловАсинх();
		#КонецЕсли
		ЗакончитьОткрытьФайл(ИмяВыбранногоКаталога, ПередаваемыеФайлы);
	Иначе
		ОткрытьФайлыБезРасширения(ПередаваемыеФайлы);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФайлыБезРасширения(ПередаваемыеФайлы) 
	
	Для каждого Описание Из ПередаваемыеФайлы Цикл
		Фрагменты = СтрРазделить(Описание.Имя, "\");
		ПолучитьФайл(Описание.Хранение, Фрагменты[Фрагменты.ВГраница()]);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Асинх Процедура ЗакончитьОткрытьФайл(ИмяВыбранногоКаталога, ПередаваемыеФайлы)
	Попытка
		ПереданныеФайлы = Ждать ПолучитьФайлыССервераАсинх(ПередаваемыеФайлы, ИмяВыбранногоКаталога);
	Исключение
		ТекстПредупреждения = НСтр("ru='Ошибка получения файлов.%СимволыПС%Возможно не выбран каталог сохранения в настройках пользователя.'", "ru");
		ТекстПредупреждения = СтрЗаменить(ТекстПредупреждения, "%СимволыПС%", Символы.ПС);
		Ждать ПредупреждениеАсинх(ТекстПредупреждения);
	КонецПопытки;
	Если ПереданныеФайлы = Неопределено Или Не ПереданныеФайлы.Количество() Тогда
		Возврат;
	КонецЕсли;
	Для каждого Описание Из ПереданныеФайлы Цикл
		Попытка
			Ждать ЗапуститьПриложениеАсинх(Описание.ПолноеИмя);
		Исключение
			ТекстСообщения = НСтр("ru='Ошибка открытия файла %ИмяФайла%'", "ru");
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%ИмяФайла%", Описание.Имя);
			Сообщить(ТекстСообщения);
		КонецПопытки;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура СписокПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура СписокПеретаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	СтандартнаяОбработка = Ложь;  	
	ПомещаемыеФайлы = Новый Массив;
	ПеретаскиваемоеЗначение = ПараметрыПеретаскивания.Значение;	
	Если ТипЗнч(ПеретаскиваемоеЗначение) = Тип("СсылкаНаФайл") Тогда 		
		ПомещаемыеФайлы.Добавить(ПеретаскиваемоеЗначение); 		
	ИначеЕсли ТипЗнч(ПеретаскиваемоеЗначение) = Тип("Массив") Тогда		
		Для Каждого ПеретаскиваемыйЭлемент Из ПеретаскиваемоеЗначение Цикл
			Если ТипЗнч(ПеретаскиваемыйЭлемент) = Тип("СсылкаНаФайл") Тогда 				
				ПомещаемыеФайлы.Добавить(ПеретаскиваемыйЭлемент);   				
			КонецЕсли;
		КонецЦикла;		
	КонецЕсли;
	
	Если ПомещаемыеФайлы.Количество() > 0 Тогда
		ВыполнитьСписокПеретаскивание(ПомещаемыеФайлы);
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьСписокПеретаскивание(ПомещаемыеФайлы)
	ДопПараметры = Новый Структура (); 
	ДопПараметры.Вставить("Владелец", ПолучитьЗначениеВладельца());				
	ОХодеПомещенияФайлов = Новый ОписаниеОповещения("ХодПомещенияФайлов", ЭтотОбъект, ДопПараметры);
	ПередПомещенияФайлов = Новый ОписаниеОповещения("ПередПомещениемФайлов", ЭтотОбъект, ДопПараметры);
	Попытка
		ПомещенныеФайлы = Ждать ПоместитьФайлыНаСерверАсинх(ОХодеПомещенияФайлов, ПередПомещенияФайлов, ПомещаемыеФайлы, УникальныйИдентификатор);
	Исключение
		Ждать ПредупреждениеАсинх(НСтр("ru='Ошибка помещения файлов на сервер'", "ru"));
	КонецПопытки;
	Если ПомещенныеФайлы = Неопределено Или ПомещенныеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли; 	
	Файлы = Новый Массив();	
	Для Каждого Файл Из ПомещенныеФайлы Цикл
		ТекущиеПомещаемыеФайлы.Удалить(Файл.СсылкаНаФайл.ИдентификаторФайла);
		Если Не Файл.ПомещениеФайлаОтменено Тогда
		  	ПереданныйФайл = Новый Структура;
		  	ПереданныйФайл.Вставить("Имя", Файл.СсылкаНаФайл.Имя);
		  	ПереданныйФайл.Вставить("Адрес", Файл.Адрес);		  
		  	Файлы.Добавить(ПереданныйФайл);
		КонецЕсли;
	КонецЦикла; 	
	Если ТекущиеПомещаемыеФайлы.Количество() = 0 Тогда
		ПоказатьЗавершениеЗагрузки();
	КонецЕсли;
	Попытка
		ПослеПомещенияФайловНаСервере(Файлы, ДопПараметры);
		Элементы.Список.Обновить();	
	Исключение
		ОбработкаОшибок.ПоказатьИнформациюОбОшибке(ИнформацияОбОшибке());
	КонецПопытки;
КонецПроцедуры

&НаКлиенте
Процедура ПриОшибкеПомещения(ИнформацияОбОшибке, СтандартнаяОбработка, ДопПараметры) Экспорт
	СтандартнаяОбработка = Ложь;
	ТекущиеПомещаемыеФайлы.Очистить();
	Элементы.ИндикаторПрогресса.Видимость = Ложь;
	Элементы.СообщениеОбОшибке.Видимость = Истина;
	СообщениеОбОшибке = ИнформацияОбОшибке.Описание;	
КонецПроцедуры

&НаКлиенте
Процедура ПередПомещениемФайлов(ПомещаемыеФайлы, ОтказОтПомещенияВсехФайлов, ДопПараметры) Экспорт 
	Для Каждого Файл Из ПомещаемыеФайлы Цикл
		ТекущиеПомещаемыеФайлы.Вставить(Файл.ИдентификаторФайла, 0);
	КонецЦикла;
	ИндикаторПрогресса = ПолучитьОбщийПрогесс();
	Элементы.ИндикаторПрогресса.Видимость = Истина;
	Элементы.СообщениеОбОшибке.Видимость = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ХодПомещенияФайлов(ПомещаемыйФайл, Помещено, ОтказОтПомещенияФайла, ПомещеноВсего, ОтказОтПомещенияВсехФайлов, ДопПараметры) Экспорт	
	ТекущиеПомещаемыеФайлы[ПомещаемыйФайл.ИдентификаторФайла] = Помещено;
	ИндикаторПрогресса = ПолучитьОбщийПрогесс();                                	
КонецПроцедуры

&НаКлиенте
Процедура ПослеПомещенияФайлов(ПомещенныеФайлы, ДопПараметры) Экспорт  	
	Если ПомещенныеФайлы = Неопределено Или ПомещенныеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли; 	
	Файлы = Новый Массив();	
	Для Каждого Файл из ПомещенныеФайлы Цикл
		ТекущиеПомещаемыеФайлы.Удалить(Файл.СсылкаНаФайл.ИдентификаторФайла);
		Если Не Файл.ПомещениеФайлаОтменено Тогда
		  	ПереданныйФайл = Новый Структура;
		  	ПереданныйФайл.Вставить("Имя", Файл.СсылкаНаФайл.Имя);
		  	ПереданныйФайл.Вставить("Адрес", Файл.Адрес);		  
		  	Файлы.Добавить(ПереданныйФайл);
		КонецЕсли;
	КонецЦикла; 	
	Если ТекущиеПомещаемыеФайлы.Количество() = 0 Тогда
		ПоказатьЗавершениеЗагрузки();
	КонецЕсли;
	Попытка
		ПослеПомещенияФайловНаСервере(Файлы, ДопПараметры);
		Элементы.Список.Обновить();	
	Исключение
		ОбработкаОшибок.ПоказатьИнформациюОбОшибке(ИнформацияОбОшибке());
	КонецПопытки;
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ПослеПомещенияФайловНаСервере(ПомещенныеФайлы, ДопПараметры)	
	Для каждого Файл Из ПомещенныеФайлы Цикл		
		ХранимыйФайл = Справочники.ХранимыеФайлы.СоздатьЭлемент();
		ХранимыйФайл.Владелец = ДопПараметры.Владелец;
		ХранимыйФайл.Наименование = Файл.Имя;
		ХранимыйФайл.ИмяФайла = Файл.Имя;
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(Файл.Адрес);
		ХранимыйФайл.ДанныеФайла = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных());
		ХранимыйФайл.Записать();		
	КонецЦикла;		
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьЗавершениеЗагрузки() Экспорт        		
	ПодключитьОбработчикОжидания("СкрытьИндикаторПрогресса", 1, Истина);
КонецПроцедуры

&НаКлиенте
Процедура СкрытьИндикаторПрогресса() Экспорт        		
	Элементы.ИндикаторПрогресса.Видимость = Ложь;
КонецПроцедуры

&НаКлиенте
Функция ПолучитьОбщийПрогесс()
	Количество = ТекущиеПомещаемыеФайлы.Количество();
	Если Количество = 0 Тогда
		Возврат 0;
	КонецЕсли;
	
	Сумма = 0;
	Для Каждого ТекущийПомещаемыеФайлы Из ТекущиеПомещаемыеФайлы Цикл
		Сумма = Сумма + ТекущийПомещаемыеФайлы.Значение;
	КонецЦикла;
	
	Возврат Сумма / Количество;
КонецФункции

&НаКлиенте
Процедура СкачатьАрхивом(Команда)
	Файлы = Новый Массив();	
	Для каждого Строка Из Элементы.Список.ВыделенныеСтроки Цикл		
		ДанныеСтроки = Элементы.Список.ДанныеСтроки(Строка);
		Файл = Новый ОписаниеПередаваемогоФайла();
		Файл.Имя = ДанныеСтроки.ИмяФайла;
		Файл.Хранение = ПолучитьНавигационнуюСсылку(Строка, "ДанныеФайла");
		Файлы.Добавить(Файл);		
	КонецЦикла;	
	ПараметрыАрхива = Новый ПараметрыПолученияАрхиваФайлов();
	ПараметрыАрхива.Режим = РежимПолученияАрхиваФайлов.ПолучатьАрхивВсегда;
	ВыполнитьСкачатьАрхивом(Файлы, ПараметрыАрхива);
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьСкачатьАрхивом(Файлы, ПараметрыАрхива)
	Диа = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	Диа.Фильтр = "*.zip|*.zip";
	МассивИменВыбранныхФайлов = Ждать Диа.ВыбратьАсинх();
	ИмяФайлаАрхива = МассивИменВыбранныхФайлов[0];
	Попытка
		Ждать ПолучитьФайлыССервераАсинх(Файлы, ИмяФайлаАрхива, ПараметрыАрхива);
		ТекстПредупреждения = НСтр("ru='Файл %ИмяФайлаАрхива% получен.'", "ru");
	Исключение
		ТекстПредупреждения = НСтр("ru='Ошибка получения архива в файл %ИмяФайлаАрхива%'", "ru");
	КонецПопытки;
	ТекстПредупреждения = СтрЗаменить(ТекстПредупреждения, "%ИмяФайлаАрхива%", ИмяФайлаАрхива);
	Ждать ПредупреждениеАсинх(ТекстПредупреждения);
КонецПроцедуры

