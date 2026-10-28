class_name NullPresenter
extends RefCounted
## A presenter that shows nothing and decides nothing: used for AI-only games (the headless simulation).
## It also documents every method the rules engine calls on a presenter.

func sync() -> void: pass                                   # state changed: redraw
func sleep(_ms: float) -> void: pass                        # pacing pause
func toast(_text: String) -> void: pass                     # a short notice
func ask(_spec: Dictionary): return null                    # {title, text, options:[{label,sub,value,disabled}], buttons:[{label,value,primary}], encounter?, locked?}
func ask_yn(_title: String, _text: String, _yes: String, _no: String) -> bool: return false
func show_event(_e: Dictionary) -> void: pass               # the day's event card
func show_secret_encounter(_e: Dictionary, _mine: bool) -> void: pass
func human_turn(): return null                              # returns {key, kind, pre}
func human_pre(_key: String, _kind: String, _no_cancel: bool): return {}
func cadaver_picks(_p: Dictionary, _cards: Array, _o: Dictionary) -> Dictionary: return {}
func choose_scoundrel(_p: Dictionary, _row: Array, _intro: String, _can_cancel: bool): return null
func placed(_i: int, _key: String, _kind: String, _bumped) -> void: pass   # a meeple was placed (animate it)
func rival_moved(_i: int, _key: String, _kind: String, _lines: Array) -> void: pass
func human_night() -> void: pass                            # the human's laboratory, until they end the night
func throw_dialog(_dice: Array, _st: Dictionary, _rolled: Array, _opts: Array): return "ok"
func throw_result(_notes: Array, _alive: bool) -> void: pass
func dawn_report(_round: int, _lines: Array, _footer: String) -> void: pass
