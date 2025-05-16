#import "../lib.typ": *

= Анализ полученного решения

В данной главе будут рассмотрены и проанализированы результаты, достигнутые при реализации интерпретатора.

== Воспроизведение примеров

Для валидации полученных результатов на полученной реализации интерпретатора эффектов высших порядков были реализованы и проверены на корректность результата примеры программ с алгебраическими эффектами, примеры программ, проверяющих корректность работы конструкции `embed` и примеры программ с эффектами, описанными в @handlers_in_scope[статье].

#note[Наверное стоит пощадить людей и писать в синтаксисе который был всю дорогу а не светить нашим эмбеддингом?]

=== Базовые примеры

=== Взаимодействие эффектов

Для проверки работы взаимодействия эффектов были протестированы 2 эффекта и способы их взаимодействия:

1. Транзакционный `try/catch`

#figure(
  ```
  withStdLib {
  withCatch = fix((rec) => (comp) =>
     withHandler
      return x --> inr(x)
      throw(e) k --> inl(e)
      catch(comp, hdl), k1 --> embed(k1,
          case (rec(comp))
            inl err -> do(#catch, abort", (() => embed(k1, hdl(err))))
            inr x   -> x
      )
      abort(m) _ --> m()
      #catch
      comp()
  );
  case(
      withCatch {
          withState("u", 42) 
          {catch({put("u", 1); throw(2)}, (_) => get("u"))}})
    inl _ -> 0
    inr z -> z 
  }
  ```
  , caption: [Пример программы с взаимодействующим эффектов обработки исключений]
)


2. Конкурентность с разделением глобального и локального состояния хендлеров для корутин.

#figure(
  ```
  withState("taskQueue", nil)
  hSchedule = {(scope) => 
    withHandler {
        return x -> x
        fork(arg) k ->
            q = get("taskQueue");
            put("taskQueue", cons(k, q));
            Embed(k,
            {arg(); do(#schedule, finish)}
            )
        yield() k ->
            q = get("taskQueue")
            if (listIsEmpty(q))
                k(unit)
            else {
              nq = listSplitLast(q);
              put("taskQueue", cons(k, nq.2));
              nq.1(unit)
            }
        finish() k -> 
            q = get("taskQueue")
            if (listIsEmpty(q))
                unit
            else {
              nq = listSplitLast(q);
              put("taskQueue", nq.2);
              nq.1(unit)
            }
        #schedule
        }
    scope()}
  ```
  , caption: [Пример программы с взаимодействующим эффектов обработки исключений]
)
