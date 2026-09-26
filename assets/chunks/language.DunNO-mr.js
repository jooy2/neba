import{j as r}from"./jsx-runtime.BjG_zV1W.js";import{r as p}from"./index.BC-ZOPMe.js";import{S as e}from"./Select.DkMgj3nG.js";import{C as a}from"./CodeBlock.Ck54ofWB.js";import"./icons.CMYhfmvL.js";import"./sizer.BCa8mhlZ.js";import"./styles.BouEvDw_.js";import"./defaults.D04ek_WJ.js";import"./notch.DTqpn9cm.js";import"./FieldDescription.bxdRv6Iz.js";import"./useIsoLayoutEffect.B9-mVwRe.js";import"./useStableCallback.v-9MKhCV.js";import"./useRenderElement.CCEyB-eT.js";import"./LabelableContext.CsJGCGFX.js";import"./FieldItemContext.DFzNeI8I.js";import"./useTimeout.EFG38DU6.js";import"./useOnMount.B7-KKtqz.js";import"./useBaseUiId.Dp1CTz-P.js";import"./useId.CEeLUmB4.js";import"./useLabel.DjOPMBYG.js";import"./floating-ui.utils.dom.D95iXyUo.js";import"./owner.CQsS7OFZ.js";import"./useRegisteredLabelId.BjhmFp8h.js";import"./shadowDom.BCctGyBD.js";import"./useOpenChangeComplete.1OR5iUSF.js";import"./index.DwoOgAgp.js";import"./useAnimationFrame.Cu4oSh6l.js";import"./stateAttributesMapping.DqawBeMT.js";import"./useTransitionStatus.CKGHEbQq.js";import"./glow.D2kcsHwd.js";import"./fieldset.QYP_gSmq.js";import"./useValueAsRef.C1M4yx3u.js";import"./popupTriggerMap.DoaXA5M0.js";import"./addEventListener.C7Nm7Zds.js";import"./ReactStore.DVfvRhJ3.js";import"./visuallyHidden.COI6QeQH.js";import"./os.B65mW8VI.js";import"./shared.D1277sO_.js";import"./engine.CviprF53.js";import"./composite.CgbFkjsu.js";import"./event.DyBKA6N4.js";import"./env.DL7APVbR.js";import"./constants.M0vQPnEJ.js";import"./createBaseUIEventDetails.C-SHKnaN.js";import"./index.Bd9dkXIU.js";import"./element.CVvgLIJ7.js";import"./getPseudoElementBounds.DUOh2qpK.js";import"./useRegisterFieldControl.onxeMGvJ.js";import"./resolveAriaLabelledBy.CqSGvM1m.js";import"./useButton.6fLBSNpQ.js";import"./resolveValueLabel.NumNgINo.js";import"./areArraysEqual.DROtyGZu.js";import"./serializeValue.B8e3iXO-.js";import"./isElementDisabled.CwHw_lZC.js";import"./useControlled.CXGP4YWF.js";import"./useValueChanged.BbDSyUsu.js";import"./useOpenInteractionType.BBbaavoI.js";import"./styles.DvwSxmKj.js";import"./clamp.DyuOe9kr.js";import"./useFloatingRootContext.CwPz3jpQ.js";import"./useClick.CiHrmi2r.js";import"./useListNavigation.Cm9K3GBR.js";import"./useScrollLock.By-96LsX.js";import"./popupStoreUtils.CIsQPvSA.js";import"./inertValue.RJvVaVO3.js";import"./CompositeList.Dx2u6OYu.js";import"./useCompositeListItem.BPIRFCEF.js";import"./usePositioner.CvijxStr.js";import"./DirectionContext.B81d2k_U.js";import"./useAnchoredPopupScrollLock.Ck_5Mq5e.js";import"./ToolbarRootContext.DEpPgnij.js";import"./composite.CMxVwWo1.js";import"./CSPContext.yg0LqTNN.js";import"./i18n.QqYapR6g.js";import"./cache.DjsaJSNf.js";import"./observe.D2XLDznJ.js";import"./framework.BoUsC9QI.js";const i={tsx:`export function Greeting({ name }: { name: string }) {
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
}`};function It(){const[o,m]=p.useState("tsx");return r.jsxs("div",{className:"flex w-full flex-col gap-4",children:[r.jsx(e,{size:"sm",label:"Language",items:Object.keys(i).map(t=>({value:t,label:t})),value:o,onValueChange:t=>m(String(t))}),r.jsx(a,{code:i[o],language:o})]})}export{It as default};
