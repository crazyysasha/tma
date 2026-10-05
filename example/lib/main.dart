import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tma/tma.dart';

void main() {
  final tma = Tma.instance;
  // Telegram shows a placeholder until ready() is called. Outside Telegram
  // these are no-ops, so no branching is needed.
  tma.ready();
  tma.expand();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tma = Tma.instance;
    return StreamBuilder<void>(
      stream: tma.events.themeChanged,
      builder: (context, _) {
        final tp = tma.themeParams;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: tp.buttonColor ?? Colors.blue,
              brightness:
                  tma.colorScheme == TmaColorScheme.dark
                      ? Brightness.dark
                      : Brightness.light,
            ),
            scaffoldBackgroundColor: tp.bgColor,
            visualDensity: VisualDensity.compact,
          ),
          home: const DemoPage(),
        );
      },
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final tma = Tma.instance;
  final log = <String>[];
  final subs = <StreamSubscription<Object?>>[];

  // Inputs shared by several sections.
  final storageKey = TextEditingController(text: 'demo_key');
  final storageValue = TextEditingController(text: 'hello');
  final url = TextEditingController(text: 'https://telegram.org');
  final tgLink = TextEditingController(text: 'https://t.me/telegram');
  final invoiceUrl = TextEditingController(text: 'https://t.me/\$invoice_slug');
  final preparedMsgId = TextEditingController();
  final emojiId = TextEditingController(text: '5368324170671202286');
  final mediaUrl = TextEditingController(
    text: 'https://telegram.org/img/t_logo.png',
  );
  final inlineQuery = TextEditingController(text: 'hello');
  final sendDataText = TextEditingController(text: '{"action":"demo"}');
  final biometricToken = TextEditingController(text: 'token-123');
  final mainButtonText = TextEditingController(text: 'Main button');
  final secondaryButtonText = TextEditingController(text: 'Secondary');
  final headerHex = TextEditingController(text: '#ff6600');

  @override
  void initState() {
    super.initState();
    _subscribeToEverything();
  }

  @override
  void dispose() {
    for (final s in subs) {
      s.cancel();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers

  void _log(Object message) {
    if (!mounted) return;
    setState(() => log.insert(0, '${_time()}  $message'));
  }

  static String _time() {
    final t = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  /// Runs an action and logs its result or exception. Never throws, so a
  /// missing Telegram environment just shows up in the log.
  Future<void> _run(String name, FutureOr<Object?> Function() action) async {
    try {
      final result = await action();
      _log('$name → ${_format(result)}');
    } on TmaException catch (e) {
      _log('$name ✗ $e');
    } catch (e) {
      _log('$name ✗ $e');
    }
  }

  /// Void SDK methods are chainable in JavaScript and hand back the JS
  /// object; show those as a plain "ok" instead of "[object Object]".
  static String _format(Object? result) {
    if (result == null) return 'ok';
    final text = '$result';
    return text.startsWith('[object ') ? 'ok' : text;
  }

  void _subscribeToEverything() {
    final e = tma.events;
    void on<T>(
      String name,
      Stream<T> stream, [
      String Function(T value)? format,
    ]) {
      subs.add(
        stream.listen((v) {
          _log('event $name${format == null ? '' : ': ${format(v)}'}');
          // Properties shown in the UI may have changed.
          if (mounted) setState(() {});
        }),
      );
    }

    on('activated', e.activated);
    on('deactivated', e.deactivated);
    on('themeChanged', e.themeChanged);
    on(
      'viewportChanged',
      e.viewportChanged,
      (v) => 'stable=${v.isStateStable}',
    );
    on('safeAreaChanged', e.safeAreaChanged);
    on('contentSafeAreaChanged', e.contentSafeAreaChanged);
    on('mainButtonClicked', e.mainButtonClicked);
    on('secondaryButtonClicked', e.secondaryButtonClicked);
    on('backButtonClicked', e.backButtonClicked);
    on('settingsButtonClicked', e.settingsButtonClicked);
    on('invoiceClosed', e.invoiceClosed, (v) => '${v.status.name} ${v.url}');
    on('popupClosed', e.popupClosed, (v) => 'button=${v.buttonId}');
    on('qrTextReceived', e.qrTextReceived, (v) => v.data);
    on('scanQrPopupClosed', e.scanQrPopupClosed);
    on('clipboardTextReceived', e.clipboardTextReceived, (v) => '${v.data}');
    on(
      'writeAccessRequested',
      e.writeAccessRequested,
      (v) => 'allowed=${v.allowed}',
    );
    on('contactRequested', e.contactRequested);
    on('fullscreenChanged', e.fullscreenChanged);
    on('fullscreenFailed', e.fullscreenFailed, (v) => v.error);
    on('homeScreenAdded', e.homeScreenAdded);
    on('homeScreenChecked', e.homeScreenChecked, (v) => v.status.name);
    on('emojiStatusSet', e.emojiStatusSet);
    on('emojiStatusFailed', e.emojiStatusFailed, (v) => v.error);
    on('emojiStatusAccessRequested', e.emojiStatusAccessRequested);
    on('shareMessageSent', e.shareMessageSent);
    on('shareMessageFailed', e.shareMessageFailed, (v) => v.error);
    on(
      'fileDownloadRequested',
      e.fileDownloadRequested,
      (v) => 'accepted=${v.accepted}',
    );
    on('locationManagerUpdated', e.locationManagerUpdated);
    on('locationRequested', e.locationRequested);
    on('biometricManagerUpdated', e.biometricManagerUpdated);
    on(
      'biometricAuthRequested',
      e.biometricAuthRequested,
      (v) => 'auth=${v.isAuthenticated} token=${v.token}',
    );
    on(
      'biometricTokenUpdated',
      e.biometricTokenUpdated,
      (v) => 'updated=${v.isUpdated}',
    );
    on('requestedChatSent', e.requestedChatSent);
    on('requestedChatFailed', e.requestedChatFailed, (v) => v.error);
  }

  // ---------------------------------------------------------------------------
  // Build

  @override
  Widget build(BuildContext context) {
    final insets = tma.safeAreaInset + tma.contentSafeAreaInset;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: insets.toEdgeInsets(),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  children: [
                    _environmentSection(),
                    _initDataSection(),
                    _themeSection(),
                    _appearanceSection(),
                    _lifecycleSection(),
                    _buttonsSection(),
                    _hapticsSection(),
                    _dialogsSection(),
                    _permissionsSection(),
                    _linksSection(),
                    _sharingSection(),
                    _cloudStorageSection(),
                    _deviceStorageSection(),
                    _secureStorageSection(),
                    _biometricsSection(),
                    _locationSection(),
                    _sensorsSection(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              _logPanel(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sections

  Widget _environmentSection() {
    return _Section(
      title: 'Environment',
      initiallyExpanded: true,
      children: [
        if (!tma.isAvailable)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Not inside Telegram. Every action below still runs: '
              'commands are no-ops, permission requests return false, '
              'data requests throw TmaUnavailableException.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        _Props({
          'environment': tma.environment.name,
          'isAvailable': tma.isAvailable,
          'unavailableReason': tma.unavailableReason?.name,
          'platform': '${tma.platform} (${tma.platform.kind.name})',
          'version': tma.version,
          'isVersionAtLeast(8.0)': tma.isVersionAtLeast(const TmaVersion(8, 0)),
          'colorScheme': tma.colorScheme.name,
          'isActive': tma.isActive,
          'isExpanded': tma.isExpanded,
          'isFullscreen': tma.isFullscreen,
          'isOrientationLocked': tma.isOrientationLocked,
          'isClosingConfirmationEnabled': tma.isClosingConfirmationEnabled,
          'isVerticalSwipesEnabled': tma.isVerticalSwipesEnabled,
          'viewportHeight': tma.viewportHeight,
          'viewportStableHeight': tma.viewportStableHeight,
          'safeAreaInset': tma.safeAreaInset,
          'contentSafeAreaInset': tma.contentSafeAreaInset,
          'headerColor': tma.headerColor,
          'backgroundColor': tma.backgroundColor,
          'bottomBarColor': tma.bottomBarColor,
        }),
        _Buttons([_Btn('Refresh', () => setState(() {}))]),
      ],
    );
  }

  Widget _initDataSection() {
    final d = tma.initData;
    return _Section(
      title: 'Init data',
      children: [
        if (d == null)
          const Text('initData is empty (null).')
        else
          _Props({
            'user.id': d.user?.id,
            'user.fullName': d.user?.fullName,
            'user.username': d.user?.username,
            'user.languageCode': d.user?.languageCode,
            'user.isPremium': d.user?.isPremium,
            'user.allowsWriteToPm': d.user?.allowsWriteToPm,
            'user.photoUrl': d.user?.photoUrl,
            'receiver': d.receiver,
            'chat': d.chat,
            'chatType': d.chatType?.name,
            'chatInstance': d.chatInstance,
            'startParam': d.startParam,
            'queryId': d.queryId,
            'chatJoinRequestQueryId': d.chatJoinRequestQueryId,
            'canSendAfter': d.canSendAfter,
            'authDate': d.authDate,
            'older than 1h': d.isOlderThan(const Duration(hours: 1)),
            'hash': _short(d.hash),
            'signature': _short(d.signature),
            'raw length': tma.initDataRaw.length,
          }),
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Everything here is unverified. Send initDataRaw to the backend '
            'and validate the hash there.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _themeSection() {
    final tp = tma.themeParams.toJson();
    return _Section(
      title: 'Theme params',
      children: [
        if (tp.isEmpty) const Text('No theme params.'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in tp.entries)
              Chip(
                avatar: CircleAvatar(
                  backgroundColor: ThemeParams.parseHexColor(entry.value),
                ),
                label: Text('${entry.key} ${entry.value}'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _appearanceSection() {
    return _Section(
      title: 'Appearance',
      children: [
        _Field(headerHex, 'Custom color (#rrggbb)'),
        _Buttons([
          _Btn(
            'Header: bg',
            () => _run(
              'setHeaderColor',
              () => tma.setHeaderColor(const HeaderColor.bg()),
            ),
          ),
          _Btn(
            'Header: secondaryBg',
            () => _run(
              'setHeaderColor',
              () => tma.setHeaderColor(const HeaderColor.secondaryBg()),
            ),
          ),
          _Btn(
            'Header: custom',
            () => _run(
              'setHeaderColor',
              () => tma.setHeaderColor(HeaderColor.custom(_customColor())),
            ),
          ),
          _Btn(
            'Background: bg',
            () => _run(
              'setBackgroundColor',
              () => tma.setBackgroundColor(const BarColor.bg()),
            ),
          ),
          _Btn(
            'Background: custom',
            () => _run(
              'setBackgroundColor',
              () => tma.setBackgroundColor(BarColor.custom(_customColor())),
            ),
          ),
          _Btn(
            'Bottom bar: bottomBarBg',
            () => _run(
              'setBottomBarColor',
              () => tma.setBottomBarColor(const BarColor.bottomBarBg()),
            ),
          ),
          _Btn(
            'Bottom bar: custom',
            () => _run(
              'setBottomBarColor',
              () => tma.setBottomBarColor(BarColor.custom(_customColor())),
            ),
          ),
        ]),
        const Divider(),
        _Buttons([
          _Btn(
            'requestFullscreen',
            () => _run('requestFullscreen', tma.requestFullscreen),
          ),
          _Btn(
            'exitFullscreen',
            () => _run('exitFullscreen', tma.exitFullscreen),
          ),
          _Btn(
            'lockOrientation',
            () => _run('lockOrientation', tma.lockOrientation),
          ),
          _Btn(
            'unlockOrientation',
            () => _run('unlockOrientation', tma.unlockOrientation),
          ),
          _Btn(
            'enableClosingConfirmation',
            () => _run(
              'enableClosingConfirmation',
              tma.enableClosingConfirmation,
            ),
          ),
          _Btn(
            'disableClosingConfirmation',
            () => _run(
              'disableClosingConfirmation',
              tma.disableClosingConfirmation,
            ),
          ),
          _Btn(
            'enableVerticalSwipes',
            () => _run('enableVerticalSwipes', tma.enableVerticalSwipes),
          ),
          _Btn(
            'disableVerticalSwipes',
            () => _run('disableVerticalSwipes', tma.disableVerticalSwipes),
          ),
        ]),
      ],
    );
  }

  Color _customColor() =>
      ThemeParams.parseHexColor(headerHex.text) ?? Colors.orange;

  Widget _lifecycleSection() {
    return _Section(
      title: 'Lifecycle',
      children: [
        _Buttons([
          _Btn('ready', () => _run('ready', tma.ready)),
          _Btn('expand', () => _run('expand', tma.expand)),
          _Btn('hideKeyboard', () => _run('hideKeyboard', tma.hideKeyboard)),
          _Btn(
            'addToHomeScreen',
            () => _run('addToHomeScreen', tma.addToHomeScreen),
          ),
          _Btn(
            'checkHomeScreenStatus',
            () => _run(
              'checkHomeScreenStatus',
              () async => (await tma.checkHomeScreenStatus()).name,
            ),
          ),
          _Btn('close', () => _run('close', tma.close)),
          _Btn(
            'close(returnBack)',
            () => _run('close(returnBack)', () => tma.close(returnBack: true)),
          ),
        ]),
      ],
    );
  }

  Widget _buttonsSection() {
    final mb = tma.mainButton;
    final sb = tma.secondaryButton;
    return _Section(
      title: 'Buttons',
      children: [
        const _SubTitle('BackButton'),
        _Props({'isVisible': tma.backButton.isVisible}),
        _Buttons([
          _Btn('show', () => _run('backButton.show', tma.backButton.show)),
          _Btn('hide', () => _run('backButton.hide', tma.backButton.hide)),
        ]),
        const _SubTitle('SettingsButton'),
        _Props({'isVisible': tma.settingsButton.isVisible}),
        _Buttons([
          _Btn(
            'show',
            () => _run('settingsButton.show', tma.settingsButton.show),
          ),
          _Btn(
            'hide',
            () => _run('settingsButton.hide', tma.settingsButton.hide),
          ),
        ]),
        const _SubTitle('MainButton'),
        _Props({
          'text': mb.text,
          'color': mb.color,
          'textColor': mb.textColor,
          'isVisible': mb.isVisible,
          'isActive': mb.isActive,
          'hasShineEffect': mb.hasShineEffect,
          'isProgressVisible': mb.isProgressVisible,
        }),
        _Field(mainButtonText, 'Main button text'),
        _bottomButtonControls('mainButton', mb, mainButtonText),
        const _SubTitle('SecondaryButton'),
        _Props({
          'text': sb.text,
          'isVisible': sb.isVisible,
          'isActive': sb.isActive,
          'position': sb.position?.name,
        }),
        _Field(secondaryButtonText, 'Secondary button text'),
        _bottomButtonControls('secondaryButton', sb, secondaryButtonText),
        _Buttons([
          for (final p in SecondaryButtonPosition.values)
            _Btn(
              'position: ${p.name}',
              () => _run(
                'secondaryButton.setParams',
                () => sb.setParams(BottomButtonParams(position: p)),
              ),
            ),
        ]),
      ],
    );
  }

  Widget _bottomButtonControls(
    String name,
    BottomButton b,
    TextEditingController text,
  ) {
    return _Buttons([
      _Btn('setText', () => _run('$name.setText', () => b.setText(text.text))),
      _Btn('show', () => _run('$name.show', b.show)),
      _Btn('hide', () => _run('$name.hide', b.hide)),
      _Btn('enable', () => _run('$name.enable', b.enable)),
      _Btn('disable', () => _run('$name.disable', b.disable)),
      _Btn('showProgress', () => _run('$name.showProgress', b.showProgress)),
      _Btn(
        'showProgress(leaveActive)',
        () =>
            _run('$name.showProgress', () => b.showProgress(leaveActive: true)),
      ),
      _Btn('hideProgress', () => _run('$name.hideProgress', b.hideProgress)),
      _Btn(
        'setParams (green, shine)',
        () => _run(
          '$name.setParams',
          () => b.setParams(
            BottomButtonParams(
              text: text.text,
              color: const Color(0xFF2E7D32),
              textColor: Colors.white,
              hasShineEffect: true,
              isActive: true,
              isVisible: true,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _hapticsSection() {
    final h = tma.hapticFeedback;
    return _Section(
      title: 'Haptic feedback',
      children: [
        _Buttons([
          for (final s in HapticImpactStyle.values)
            _Btn(
              'impact ${s.name}',
              () => _run('impactOccurred', () => h.impactOccurred(s)),
            ),
          for (final t in HapticNotificationType.values)
            _Btn(
              'notification ${t.name}',
              () =>
                  _run('notificationOccurred', () => h.notificationOccurred(t)),
            ),
          _Btn(
            'selectionChanged',
            () => _run('selectionChanged', h.selectionChanged),
          ),
        ]),
      ],
    );
  }

  Widget _dialogsSection() {
    return _Section(
      title: 'Dialogs, QR, clipboard',
      children: [
        _Buttons([
          _Btn(
            'showPopup',
            () => _run(
              'showPopup',
              () => tma.showPopup(
                const PopupParams(
                  title: 'Popup',
                  message: 'Pick a button',
                  buttons: [
                    PopupButton(id: 'ok', type: PopupButtonType.ok),
                    PopupButton(id: 'custom', text: 'Custom'),
                    PopupButton(
                      id: 'del',
                      type: PopupButtonType.destructive,
                      text: 'Delete',
                    ),
                  ],
                ),
              ),
            ),
          ),
          _Btn(
            'showAlert',
            () => _run('showAlert', () => tma.showAlert('This is an alert')),
          ),
          _Btn(
            'showConfirm',
            () => _run('showConfirm', () => tma.showConfirm('Are you sure?')),
          ),
          _Btn(
            'scanQr',
            () => _run('scanQr', () => tma.scanQr(text: 'Scan any code')),
          ),
          _Btn(
            'closeScanQrPopup',
            () => _run('closeScanQrPopup', tma.closeScanQrPopup),
          ),
          _Btn(
            'readTextFromClipboard',
            () => _run('readTextFromClipboard', tma.readTextFromClipboard),
          ),
        ]),
      ],
    );
  }

  Widget _permissionsSection() {
    return _Section(
      title: 'Permissions and requests',
      children: [
        _Buttons([
          _Btn(
            'requestWriteAccess',
            () => _run('requestWriteAccess', tma.requestWriteAccess),
          ),
          _Btn(
            'requestContact',
            () => _run('requestContact', () async {
              final r = await tma.requestContact();
              return '${r.status.name} ${r.data?.contact} raw=${_short(r.data?.raw)}';
            }),
          ),
          _Btn(
            'requestChat(1)',
            () => _run('requestChat', () => tma.requestChat(1)),
          ),
          _Btn(
            'requestEmojiStatusAccess',
            () =>
                _run('requestEmojiStatusAccess', tma.requestEmojiStatusAccess),
          ),
        ]),
      ],
    );
  }

  Widget _linksSection() {
    return _Section(
      title: 'Links, invoice, bot data',
      children: [
        _Field(url, 'External URL'),
        _Buttons([
          _Btn(
            'openLink',
            () => _run('openLink', () => tma.openLink(url.text)),
          ),
          _Btn(
            'openLink(instantView)',
            () => _run(
              'openLink',
              () => tma.openLink(url.text, tryInstantView: true),
            ),
          ),
          _Btn(
            'openLink(browser)',
            () => _run(
              'openLink',
              () => tma.openLink(url.text, tryBrowser: true),
            ),
          ),
        ]),
        _Field(tgLink, 't.me link'),
        _Buttons([
          _Btn(
            'openTelegramLink',
            () => _run(
              'openTelegramLink',
              () => tma.openTelegramLink(tgLink.text),
            ),
          ),
          _Btn(
            'openTelegramLink(forceRequest)',
            () => _run(
              'openTelegramLink',
              () => tma.openTelegramLink(tgLink.text, forceRequest: true),
            ),
          ),
        ]),
        _Field(invoiceUrl, 'Invoice URL (https://t.me/\$slug)'),
        _Buttons([
          _Btn(
            'openInvoice',
            () => _run(
              'openInvoice',
              () async => (await tma.openInvoice(invoiceUrl.text)).name,
            ),
          ),
        ]),
        _Field(sendDataText, 'sendData payload (keyboard-button apps only)'),
        _Buttons([
          _Btn(
            'sendData',
            () => _run('sendData', () => tma.sendData(sendDataText.text)),
          ),
        ]),
        _Field(inlineQuery, 'Inline query'),
        _Buttons([
          _Btn(
            'switchInlineQuery',
            () => _run(
              'switchInlineQuery',
              () => tma.switchInlineQuery(inlineQuery.text),
            ),
          ),
          _Btn(
            'switchInlineQuery(users, groups)',
            () => _run(
              'switchInlineQuery',
              () => tma.switchInlineQuery(
                inlineQuery.text,
                chooseChatTypes: const [
                  ChooseChatType.users,
                  ChooseChatType.groups,
                ],
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _sharingSection() {
    return _Section(
      title: 'Sharing, emoji status, downloads',
      children: [
        _Field(mediaUrl, 'Story media URL'),
        _Buttons([
          _Btn(
            'shareToStory',
            () => _run('shareToStory', () => tma.shareToStory(mediaUrl.text)),
          ),
          _Btn(
            'shareToStory(text, widget)',
            () => _run(
              'shareToStory',
              () => tma.shareToStory(
                mediaUrl.text,
                const StoryShareParams(
                  text: 'Shared from the tma example',
                  widgetLink: StoryWidgetLink(
                    url: 'https://t.me/telegram',
                    name: 'Telegram',
                  ),
                ),
              ),
            ),
          ),
        ]),
        _Field(
          preparedMsgId,
          'Prepared message id (savePreparedInlineMessage)',
        ),
        _Buttons([
          _Btn(
            'shareMessage',
            () => _run(
              'shareMessage',
              () => tma.shareMessage(preparedMsgId.text),
            ),
          ),
        ]),
        _Field(emojiId, 'Custom emoji id'),
        _Buttons([
          _Btn(
            'setEmojiStatus',
            () =>
                _run('setEmojiStatus', () => tma.setEmojiStatus(emojiId.text)),
          ),
          _Btn(
            'setEmojiStatus(1h)',
            () => _run(
              'setEmojiStatus',
              () => tma.setEmojiStatus(
                emojiId.text,
                const EmojiStatusParams(duration: Duration(hours: 1)),
              ),
            ),
          ),
        ]),
        _Buttons([
          _Btn(
            'downloadFile',
            () => _run(
              'downloadFile',
              () => tma.downloadFile(
                DownloadFileParams(url: mediaUrl.text, fileName: 'logo.png'),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _cloudStorageSection() {
    final s = tma.cloudStorage;
    return _Section(
      title: 'CloudStorage',
      children: [
        _Field(storageKey, 'Key'),
        _Field(storageValue, 'Value'),
        _Buttons([
          _Btn(
            'setItem',
            () => _run(
              'cloud.setItem',
              () => s.setItem(storageKey.text, storageValue.text),
            ),
          ),
          _Btn(
            'getItem',
            () => _run('cloud.getItem', () => s.getItem(storageKey.text)),
          ),
          _Btn(
            'getItems([key, other])',
            () => _run(
              'cloud.getItems',
              () => s.getItems([storageKey.text, 'other']),
            ),
          ),
          _Btn('getKeys', () => _run('cloud.getKeys', s.getKeys)),
          _Btn(
            'removeItem',
            () => _run('cloud.removeItem', () => s.removeItem(storageKey.text)),
          ),
          _Btn(
            'removeItems([key, other])',
            () => _run(
              'cloud.removeItems',
              () => s.removeItems([storageKey.text, 'other']),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _deviceStorageSection() {
    final s = tma.deviceStorage;
    return _Section(
      title: 'DeviceStorage (9.0+)',
      children: [
        const Text('Uses the same key/value fields as CloudStorage.'),
        _Buttons([
          _Btn(
            'setItem',
            () => _run(
              'device.setItem',
              () => s.setItem(storageKey.text, storageValue.text),
            ),
          ),
          _Btn(
            'getItem',
            () => _run('device.getItem', () => s.getItem(storageKey.text)),
          ),
          _Btn(
            'removeItem',
            () =>
                _run('device.removeItem', () => s.removeItem(storageKey.text)),
          ),
          _Btn('clear', () => _run('device.clear', s.clear)),
        ]),
      ],
    );
  }

  Widget _secureStorageSection() {
    final s = tma.secureStorage;
    return _Section(
      title: 'SecureStorage (9.0+)',
      children: [
        const Text('Uses the same key/value fields as CloudStorage.'),
        _Buttons([
          _Btn(
            'setItem',
            () => _run(
              'secure.setItem',
              () => s.setItem(storageKey.text, storageValue.text),
            ),
          ),
          _Btn(
            'getItem',
            () => _run('secure.getItem', () async {
              final item = await s.getItem(storageKey.text);
              return 'value=${item.value} canRestore=${item.canRestore}';
            }),
          ),
          _Btn(
            'restoreItem',
            () => _run(
              'secure.restoreItem',
              () => s.restoreItem(storageKey.text),
            ),
          ),
          _Btn(
            'removeItem',
            () =>
                _run('secure.removeItem', () => s.removeItem(storageKey.text)),
          ),
          _Btn('clear', () => _run('secure.clear', s.clear)),
        ]),
      ],
    );
  }

  Widget _biometricsSection() {
    final b = tma.biometricManager;
    return _Section(
      title: 'BiometricManager',
      children: [
        _Props({
          'isInited': b.isInited,
          'isBiometricAvailable': b.isBiometricAvailable,
          'biometricType': b.biometricType.name,
          'isAccessRequested': b.isAccessRequested,
          'isAccessGranted': b.isAccessGranted,
          'isBiometricTokenSaved': b.isBiometricTokenSaved,
          'deviceId': b.deviceId,
        }),
        _Field(biometricToken, 'Token to store'),
        _Buttons([
          _Btn('init', () => _run('biometric.init', b.init)),
          _Btn(
            'requestAccess',
            () => _run(
              'biometric.requestAccess',
              () => b.requestAccess(
                const BiometricParams(reason: 'Demo needs biometrics'),
              ),
            ),
          ),
          _Btn(
            'authenticate',
            () => _run('biometric.authenticate', () async {
              final r = await b.authenticate(
                const BiometricParams(reason: 'Confirm it is you'),
              );
              return 'authenticated=${r.isAuthenticated} token=${r.token}';
            }),
          ),
          _Btn(
            'updateBiometricToken',
            () => _run(
              'biometric.updateBiometricToken',
              () => b.updateBiometricToken(biometricToken.text),
            ),
          ),
          _Btn(
            'remove token',
            () => _run(
              'biometric.updateBiometricToken',
              () => b.updateBiometricToken(''),
            ),
          ),
          _Btn(
            'openSettings',
            () => _run('biometric.openSettings', b.openSettings),
          ),
        ]),
      ],
    );
  }

  Widget _locationSection() {
    final l = tma.locationManager;
    return _Section(
      title: 'LocationManager',
      children: [
        _Props({
          'isInited': l.isInited,
          'isLocationAvailable': l.isLocationAvailable,
          'isAccessRequested': l.isAccessRequested,
          'isAccessGranted': l.isAccessGranted,
        }),
        _Buttons([
          _Btn('init', () => _run('location.init', l.init)),
          _Btn(
            'getLocation',
            () => _run('location.getLocation', l.getLocation),
          ),
          _Btn(
            'openSettings',
            () => _run('location.openSettings', l.openSettings),
          ),
        ]),
      ],
    );
  }

  Widget _sensorsSection() {
    return _Section(
      title: 'Sensors',
      children: [
        _motionSensor('Accelerometer', tma.accelerometer),
        _motionSensor('Gyroscope', tma.gyroscope),
        const _SubTitle('DeviceOrientation'),
        StreamBuilder<OrientationData>(
          stream: tma.deviceOrientation.onChanged,
          builder:
              (_, snap) => _Props({
                'isStarted': tma.deviceOrientation.isStarted,
                'value': snap.data ?? tma.deviceOrientation.value,
              }),
        ),
        _Buttons([
          _Btn(
            'start',
            () =>
                _run('orientation.start', () => tma.deviceOrientation.start()),
          ),
          _Btn(
            'start(absolute, 100ms)',
            () => _run(
              'orientation.start',
              () => tma.deviceOrientation.start(
                const DeviceOrientationParams(
                  needAbsolute: true,
                  refreshRate: Duration(milliseconds: 100),
                ),
              ),
            ),
          ),
          _Btn(
            'stop',
            () => _run('orientation.stop', tma.deviceOrientation.stop),
          ),
        ]),
      ],
    );
  }

  Widget _motionSensor(String name, MotionSensor s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubTitle(name),
        StreamBuilder<Vector3>(
          stream: s.onChanged,
          builder:
              (_, snap) => _Props({
                'isStarted': s.isStarted,
                'value': snap.data ?? s.value,
              }),
        ),
        _Buttons([
          _Btn('start', () => _run('$name.start', () => s.start())),
          _Btn(
            'start(100ms)',
            () => _run(
              '$name.start',
              () => s.start(
                const SensorParams(refreshRate: Duration(milliseconds: 100)),
              ),
            ),
          ),
          _Btn('stop', () => _run('$name.stop', s.stop)),
        ]),
      ],
    );
  }

  Widget _logPanel() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Log',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(log.clear),
                child: const Text('Clear'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: log.length,
              itemBuilder:
                  (_, i) => SelectableText(
                    log[i],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  static String? _short(String? s) =>
      s == null ? null : (s.length <= 12 ? s : '${s.substring(0, 12)}…');
}

// -----------------------------------------------------------------------------
// Small UI helpers

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(title),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _Props extends StatelessWidget {
  const _Props(this.values);
  final Map<String, Object?> values;

  @override
  Widget build(BuildContext context) {
    final style = const TextStyle(fontFamily: 'monospace', fontSize: 12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in values.entries)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: Text(
                  e.key,
                  style: style.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
              Expanded(child: SelectableText('${e.value}', style: style)),
            ],
          ),
      ],
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons(this.children);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Wrap(spacing: 6, runSpacing: 6, children: children),
  );
}

class _Btn extends StatelessWidget {
  const _Btn(this.label, this.onPressed);
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.tonal(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    onPressed: onPressed,
    child: Text(label, style: const TextStyle(fontSize: 12)),
  );
}

class _Field extends StatelessWidget {
  const _Field(this.controller, this.label);
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(fontSize: 13),
    ),
  );
}
