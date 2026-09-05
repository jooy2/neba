import{j as r}from"./jsx-runtime.BjG_zV1W.js";import{r as p}from"./index.CAJ_Adw3.js";import{S as e}from"./Select.CaTSHAGG.js";import{C as a}from"./CodeBlock.DvWOAOCu.js";import"./icons.C4HwxOCh.js";import"./sizer.BCa8mhlZ.js";import"./styles.CDlaVNd_.js";import"./defaults.UE6OgxpG.js";import"./FieldDescription.DxjWQEsT.js";import"./useIsoLayoutEffect.rsVFvFvq.js";import"./useStableCallback.zhuF4oZw.js";import"./useRenderElement.Cus7Czkm.js";import"./LabelableContext.8x-yavr8.js";import"./useFieldValidation.wYSpWgRN.js";import"./useTimeout.CyOqfRKh.js";import"./useOnMount.BI56iChy.js";import"./useBaseUiId.K-DMStxz.js";import"./useId.tHF0k50j.js";import"./useLabel.BlpnLrDj.js";import"./floating-ui.utils.dom.Dp_DHu81.js";import"./owner.CQsS7OFZ.js";import"./useRegisteredLabelId.9gFxF4t_.js";import"./shadowDom.YFMfXXXf.js";import"./useOpenChangeComplete.DqQ27BOv.js";import"./index.CicSMsZE.js";import"./useAnimationFrame.Dm-vr_VE.js";import"./stateAttributesMapping.DqawBeMT.js";import"./useTransitionStatus.DGgZUR-D.js";import"./visuallyHidden.COI6QeQH.js";import"./resolveValueLabel.D5SFylna.js";import"./areArraysEqual.DROtyGZu.js";import"./serializeValue.B8e3iXO-.js";import"./isElementDisabled.CwHw_lZC.js";import"./useControlled.DMwoNv7u.js";import"./useValueAsRef.CetTB6J-.js";import"./useLabelableId.DjyXzttG.js";import"./createBaseUIEventDetails.Bcx8_qqL.js";import"./useValueChanged.X9oXLClj.js";import"./useOpenInteractionType.BJ4LnJgL.js";import"./os.DzfHKR2B.js";import"./shared.BwuzQDa5.js";import"./styles.DvwSxmKj.js";import"./clamp.DyuOe9kr.js";import"./useFloatingRootContext.BnEzi6RC.js";import"./popupTriggerMap.D7L4P9Pr.js";import"./addEventListener.C7Nm7Zds.js";import"./ReactStore.WSFuZLam.js";import"./engine.B18q_cct.js";import"./composite.Bc5b-0Nj.js";import"./event.Dv6dYVie.js";import"./env.C3dPHKt2.js";import"./constants.333quhhN.js";import"./index.D4m2yItD.js";import"./element.CEZgQedd.js";import"./useClick.BiGeXkKg.js";import"./useListNavigation.Fa5AyCPW.js";import"./useScrollLock.D7pXnNtI.js";import"./getPseudoElementBounds.CsQxjcPR.js";import"./popupStoreUtils.BLR0nRkd.js";import"./resolveAriaLabelledBy.CqSGvM1m.js";import"./useButton.NkiMPz6P.js";import"./inertValue.D7wGFV3S.js";import"./CompositeList.CwoYhz5T.js";import"./useCompositeListItem.Cui148Cd.js";import"./usePositioner.ozjDOfEk.js";import"./DirectionContext.CJN3kIvL.js";import"./useAnchoredPopupScrollLock.CmnpkC7U.js";import"./ToolbarRootContext.D1VZU8uZ.js";import"./composite.DZHVUIgJ.js";import"./CSPContext.DHyg3PPR.js";import"./i18n.C_owC-Jx.js";import"./cache.DjsaJSNf.js";import"./framework.CKd2nDfM.js";const i={tsx:`export function Greeting({ name }: { name: string }) {
  return <p className="text-lg">Hello, {name}!</p>;
}`,python:`from dataclasses import dataclass

@dataclass
class Point:
    x: float = 0.0
    y: float = 0.0

    def scaled(self, by: float) -> "Point":
        return Point(self.x * by, self.y * by)`,yaml:`name: run-test
on:
  pull_request:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5`,sql:`SELECT p.name, count(o.id) AS orders
FROM products p
LEFT JOIN orders o ON o.product_id = p.id
WHERE p.archived_at IS NULL
GROUP BY p.name
ORDER BY orders DESC
LIMIT 10;`,rust:`fn main() {
    let names = vec!["ada", "grace", "alan"];
    for (index, name) in names.iter().enumerate() {
        println!("{index}: {name}");
    }
}`};function Rt(){const[o,m]=p.useState("tsx");return r.jsxs("div",{className:"flex w-full flex-col gap-4",children:[r.jsx(e,{size:"sm",label:"Language",items:Object.keys(i).map(t=>({value:t,label:t})),value:o,onValueChange:t=>m(String(t))}),r.jsx(a,{code:i[o],language:o})]})}export{Rt as default};
