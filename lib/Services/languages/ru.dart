import 'languages.dart';

class LanguageRu extends Languages {
  @override
  String get welcomeToFooty => "ДОБРО ПОЖАЛОВАТЬ";
  @override
  String get labelSelectLanguage => "Русский";
  @override
  String get loginScreen1head => "Онлайн бронирование";
  @override
  String get loginScreen1text =>
      "Бронируйте онлайн без проблем. Больше нет нужды связываться с администраторами и вести долгую беседу";
  @override
  String get loginScreen2head => "2 минуты";
  @override
  String get loginScreen2text =>
      "Всего лишь 2 минуты чтобы забронировать услугу в любом месте";
  @override
  String get loginScreen3head => "Комфорт";
  @override
  String get loginScreen3text =>
      "Мы предлагаем удобное расписание и систему которая регулирует и организовывает ваши броны";
  @override
  String get getStarted => "Начнем";
  @override
  String get loginScreenYourPhone => "Телефон";
  @override
  String get loginScreen6Digits => "Минимум 6 символов";
  @override
  String get loginScreenEnterCode => "Введите код";
  @override
  String get loginScreenReenterPhone => "Поменять номер телефона";
  @override
  String get loginScreenPolicy => "Продолжая вы принимаете все правила пользования приложением и нашу Политику Конфиденциальности";
@override
  String get loginScreenCodeIsNotValid => "Время действия кода истекло";


  @override
  String get homeScreenBook => "Брон";
  @override
  String get homeScreenFail => "Ошибка";
  @override
  String get homeScreenFailedToUpdate => "Не удалось обновить";
  @override
  String get homeScreenSaved => "Сохранено";


  @override
  String get searchScreenName => "Название";


  @override
  String get historyScreenSchedule => "Расписание";
  @override
  String get historyScreenHistory => "История";
  @override
  String get historyScreenUnpaid => "Неоплачено";
  @override
  String get historyScreenInProcess => "В процессе";
  @override
  String get historyScreenUpcoming => "Предстоящие";
  @override
  String get historyScreenUnrated => "Без оценки";

  @override
  String get profileScreenFavs => "Избранное";
  @override
  String get profileScreenNotifs => "Уведомления";
  @override
  String get profileScreenSignOut => "Выйти?";
  @override
  String get profileScreenWantToLeave => "Хотите выйти?";


  @override
  String get settingsSettings => "Настройки";
  @override
  String get settingsLocalPassword => "Локальный пароль";
  @override
  String get settingsLocalPasswordTurnedOff => "Локальный пароль отключен";
  @override
  String get settingsLocalPasswordTurnedOn => "Локальный пароль включен";
  @override
  String get settingsDigitPassword => "4-значный пароль";


  @override
  String get serviceScreenNoInternet => "Нет соединения с Интернетом";
}
