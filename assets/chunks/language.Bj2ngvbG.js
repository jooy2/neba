import{j as r}from"./jsx-runtime.BjG_zV1W.js";import{r as p}from"./index.BC-ZOPMe.js";import{S as e}from"./Select.AGORKGZu.js";import{C as a}from"./CodeBlock.BN1ib7AN.js";import"./icons.C4HwxOCh.js";import"./sizer.BCa8mhlZ.js";import"./styles.BhE9daFN.js";import"./defaults.D04ek_WJ.js";import"./fieldset.CGLiH9fh.js";import"./useIsoLayoutEffect.B9-mVwRe.js";import"./useStableCallback.v-9MKhCV.js";import"./useRenderElement.CCEyB-eT.js";import"./LabelableContext.CsJGCGFX.js";import"./FieldItemContext.DFzNeI8I.js";import"./useTimeout.EFG38DU6.js";import"./useOnMount.B7-KKtqz.js";import"./useBaseUiId.Dp1CTz-P.js";import"./useId.CEeLUmB4.js";import"./useLabel.DjOPMBYG.js";import"./floating-ui.utils.dom.D95iXyUo.js";import"./owner.CQsS7OFZ.js";import"./useRegisteredLabelId.BjhmFp8h.js";import"./shadowDom.BCctGyBD.js";import"./useOpenChangeComplete.1OR5iUSF.js";import"./index.DwoOgAgp.js";import"./useAnimationFrame.Cu4oSh6l.js";import"./stateAttributesMapping.DqawBeMT.js";import"./useTransitionStatus.CKGHEbQq.js";import"./visuallyHidden.COI6QeQH.js";import"./resolveValueLabel.NumNgINo.js";import"./areArraysEqual.DROtyGZu.js";import"./serializeValue.B8e3iXO-.js";import"./isElementDisabled.CwHw_lZC.js";import"./useControlled.CXGP4YWF.js";import"./useValueAsRef.C1M4yx3u.js";import"./useRegisterFieldControl.onxeMGvJ.js";import"./createBaseUIEventDetails.BFECnMVi.js";import"./useValueChanged.BbDSyUsu.js";import"./useOpenInteractionType.BpcB-5w2.js";import"./os.DaTcvaYW.js";import"./shared.BwuzQDa5.js";import"./styles.DvwSxmKj.js";import"./clamp.DyuOe9kr.js";import"./useFloatingRootContext.3a5rz9pn.js";import"./popupTriggerMap.D7MrKgP2.js";import"./addEventListener.C7Nm7Zds.js";import"./ReactStore.ZlfMEcVv.js";import"./engine.B18q_cct.js";import"./composite.DUXpQk0Y.js";import"./event.B4GKlah4.js";import"./env.C3dPHKt2.js";import"./constants.M0vQPnEJ.js";import"./index.Bd9dkXIU.js";import"./element.D0qxZtRE.js";import"./useClick.DiU906J1.js";import"./useListNavigation.hhu5ofyk.js";import"./useScrollLock.C1VsodEz.js";import"./getPseudoElementBounds.BMNz_Or1.js";import"./popupStoreUtils.DMUfV_jg.js";import"./resolveAriaLabelledBy.CqSGvM1m.js";import"./useButton.6fLBSNpQ.js";import"./inertValue.RJvVaVO3.js";import"./CompositeList.Dx2u6OYu.js";import"./useCompositeListItem.BPIRFCEF.js";import"./usePositioner.CBWtz4tA.js";import"./DirectionContext.B81d2k_U.js";import"./useAnchoredPopupScrollLock.CVFRx0_s.js";import"./ToolbarRootContext.DEpPgnij.js";import"./composite.CMxVwWo1.js";import"./CSPContext.yg0LqTNN.js";import"./i18n.CNb1bbqZ.js";import"./cache.DjsaJSNf.js";import"./observe.D2XLDznJ.js";import"./framework.CKd2nDfM.js";const i={tsx:`export function Greeting({ name }: { name: string }) {
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
}`};function Nt(){const[o,m]=p.useState("tsx");return r.jsxs("div",{className:"flex w-full flex-col gap-4",children:[r.jsx(e,{size:"sm",label:"Language",items:Object.keys(i).map(t=>({value:t,label:t})),value:o,onValueChange:t=>m(String(t))}),r.jsx(a,{code:i[o],language:o})]})}export{Nt as default};
