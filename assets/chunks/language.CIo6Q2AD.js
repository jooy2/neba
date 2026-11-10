import{j as r}from"./jsx-runtime.BjG_zV1W.js";import{r as p}from"./index.CKsxLMuf.js";import{Select as e}from"./Select.Do8v-f_t.js";import{C as a}from"./CodeBlock._-TQpsXP.js";import"./icons.C5e0GxhX.js";import"./sizer.CH8riSYa.js";import"./styles.DWChSxLs.js";import"./defaults.B6iMc8JS.js";import"./notch.DlCApJ7V.js";import"./FieldDescription.rLES4cKX.js";import"./useIsoLayoutEffect.C_Yz53OT.js";import"./useStableCallback.CFhfizr4.js";import"./useRenderElement.B1XuV26y.js";import"./useRegisterFieldControl.BvqsqtNL.js";import"./useBaseUiId.DER2YLf6.js";import"./useId.CiDKx_V-.js";import"./formatErrorMessage.ChoxhDD1.js";import"./FieldItemContext.6aEmfOXV.js";import"./useTimeout.juBJPY6t.js";import"./useOnMount.C23MP_BZ.js";import"./useLabel.-K2os8Bh.js";import"./floating-ui.utils.dom.QrHxWXrw.js";import"./owner.CQsS7OFZ.js";import"./useRegisteredLabelId.Bgyokn_B.js";import"./shadowDom.BLDFFjtV.js";import"./useOpenChangeComplete.hJXyqxf1.js";import"./index.DKXYHc88.js";import"./useAnimationFrame.CLP1Voo-.js";import"./getFiniteAnimations.BrKatd1A.js";import"./stateAttributesMapping.DqawBeMT.js";import"./useTransitionStatus.C94i9RjH.js";import"./glow.D2kcsHwd.js";import"./fieldset.raI59fvP.js";import"./useCompositeListItem.CCQtmG9n.js";import"./reason-parts.CoOhI1TC.js";import"./resolveValueLabel.LnLj825v.js";import"./areArraysEqual.DROtyGZu.js";import"./serializeValue.B8e3iXO-.js";import"./event.DnsXjI_4.js";import"./os.B65mW8VI.js";import"./shared.D1277sO_.js";import"./env.DL7APVbR.js";import"./useButton.Vp_VAXzx.js";import"./ItemIndicator.B-E4PupM.js";import"./useValueAsRef.DEKhDphr.js";import"./FloatingRootStore.Dc0NiCLV.js";import"./addEventListener.C7Nm7Zds.js";import"./ReactStore.CeU7tTYf.js";import"./visuallyHidden.BsIGJQ4u.js";import"./engine.CviprF53.js";import"./composite.Nm3he3qi.js";import"./constants.M0vQPnEJ.js";import"./index.iwerJaWv.js";import"./element.BsziWD88.js";import"./getPseudoElementBounds.Ctv7ZTAw.js";import"./resolveAriaLabelledBy.CqSGvM1m.js";import"./isElementDisabled.CwHw_lZC.js";import"./useControlled.B0fv6U_0.js";import"./useValueChanged.DtEcjZH4.js";import"./useOpenInteractionType.8GOgJwEn.js";import"./scrollEdges.BouNN4nk.js";import"./clamp.DyuOe9kr.js";import"./useFloatingRootContext.Dpt5CE25.js";import"./useClick.B_2SytHc.js";import"./useListNavigation.0R2bU8Xg.js";import"./useScrollLock.DsT2xVZV.js";import"./inertValue.CPmJEqwz.js";import"./CompositeList.BmL1icrw.js";import"./usePositioner.CSKsTU4r.js";import"./DirectionContext.Clz-vAzW.js";import"./useAnchoredPopupScrollLock.DIKgnpAx.js";import"./ToolbarRootContext.CIGn2qOJ.js";import"./composite.CSRZwaWJ.js";import"./CSPContext.BWtDjEbE.js";import"./i18n.DpuvhODr.js";import"./cache.uQL3LqyE.js";import"./observe.BgVbFSQG.js";import"./framework.xlcI8-Dy.js";const i={tsx:`export function Greeting({ name }: { name: string }) {
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
}`};function Pt(){const[o,m]=p.useState("tsx");return r.jsxs("div",{className:"flex w-full flex-col gap-4",children:[r.jsx(e,{size:"sm",label:"Language",items:Object.keys(i).map(t=>({value:t,label:t})),value:o,onValueChange:t=>m(String(t))}),r.jsx(a,{code:i[o],language:o})]})}export{Pt as default};
