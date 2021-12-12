package LS_Classes
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextFieldAutoSize;
		
	public class LSTooltipClass extends MovieClip
	{
		public var tooltipW:Number = 441;
		public var tooltipH:Number = 837;
		public var scaleH:Boolean;
		public var maxH:Number = 0;
		public var tooltipPaddingL:Number = 13;
		public var tooltipPaddingR:Number = 52;
		public var tooltipPaddingB:Number = 26;
		public var SepSpacing:Number = 16;
		public var fixedTopSpacing:int = -1;
		public var fixedFooterSpacing:int = -1;
		private const s_bottomSepSpacing:Number = 8;
		private const s_TextSpacing:Number = 4;
		public const s_WGIconSpacing:Number = 2;
		public const s_WGIconInterSpacing:Number = 12;
		private const s_WarningCol:uint = 13442847;
		private const s_ActionInfoCol:uint = 13720083;
		private const contentFadeIn:Number = 0.1;
		private const s_BonusColour:uint = 495560;
		private const s_PenaltyColour:uint = 13107248;
		public const s_BtnHintOffset:Number = 24;
		private const footerBottomPos:Number = 808;
		private const footerLabelOffset:Number = -6;
		public const s_BtnHintHOffset:Number = 8;
		private const s_bottomCompareSpacing:Number = 13;
		private var hasSubSections:Boolean = false;
		private const s_DividerSpacing:Number = 10;
		public var m_Leading:Number = 26;
		public var footerSpace:Number;
		public var list:scrollList;
		public var buttonHints:listDisplay;
		public var equipHeader:MovieClip = null;
		public var isItem:Boolean;
		public var isIdentified:Boolean;
		public var AbilityId:Number;
		public var TalentId:Number;
		public var groupLabels:Array;
		public var groupColours:Array;
		public var groupValueColours:Array;
		public var unidentifiedMC:MovieClip;
		public var forceHideFooter:Boolean = false;
		public var btnHintHOffset:Number = 0;
		public var isEquipped:Boolean = false;
		public var footer_mc:MovieClip;
		public var container_mc:MovieClip;
		public var middleBg_mc:MovieClip;
		public var header_mc:MovieClip;
		private var codeEnum:Object;
		private var grpsEnum:Object;
		
		public function LSTooltipClass(param1:* = "tt_handle", param2:* = "tt_scrollBg")
		{
			super();
			if(this.header_mc)
			{
				this.header_mc.init();
			}
			if(this.middleBg_mc)
			{
				this.middleBg_mc.base = this;
				this.middleBg_mc.init();
			}
			if(this.footer_mc)
			{
				this.footer_mc.init();
			}
			this.footerSpace = -1;
			this.list = new scrollList("","",param1,param2);
			this.list.m_scrollbar_mc.m_SCROLLSPEED = 32;
			this.list.m_scrollbar_mc.m_animateScrolling = true;
			this.list.m_scrollbar_mc.ScaleBG = true;
			this.list.m_scrollbar_mc.m_initialScrollDelay = 100;
			this.list.m_scrollbar_mc.m_scrollMultiplier = 1;
			this.list.m_scrollbar_mc.m_normaliseScrolling = true;
			this.list.TOP_SPACING = 5;
			this.list.EL_SPACING = 0;
			if(!this.container_mc)
			{
				this.container_mc = new MovieClip();
				addChild(this.container_mc);
			}
			this.container_mc.addChild(this.list);
			this.buttonHints = new listDisplay();
			this.buttonHints.y = this.s_BtnHintOffset;
			if(this.footer_mc)
			{
				this.footer_mc.btnHints_mc.addChild(this.buttonHints);
			}
			this.initArrays();
		}
		
		protected function initArrays() : void
		{
			this.groupLabels = new Array("WIP",">CRITICAL<",">SPECIAL<",">SAVING THROW<",">ACTION POINT COST<",">PROPERTIES<",">SOURCE POINT COST<",">RUNES<",">RUNE EFFECT<",">RUNE ACTIVE EFFECT<",">RUNE INACTIVE EFFECT<",">warnings<",">Skills<",">Tags<",">EmptyRunes<",">Description<",">STRMove<",">STRCarry<",">MEMSlots<",">StatsPointUp<",">StatsBonus<",">StatsMalus<",">StatsBase<",">StatsPercentageBoost<",">StatsPercentageMalus<",">StatsPercentageTotal<",">StatsGearBoostNormal<",">StatsATKAPCost<",">StatsAPTitle<",">StatsAPBase<",">StatsAPBonus<",">StatsAPMalus<",">SkillCurrentLevel<",">StatusImmunity<",">StatusBonus<",">StatusMalus<",">Duration<",">Fire<",">Water<",">Earth<",">Air<",">Poison<",">Physical<",">Sulfur<",">Heal<",">ArmorSet<");
			this.groupColours = new Array(16711884,16763904,495560,10717514,7385358,11444117,10606527,9598303,495560,495560,11444117,this.s_WarningCol,11444117,11444117,5652786,16777215,11444117,11444117,11444117,11444117,495560,13107248,495560,495560,13107248,16777215,11444117,7385358,16777215,495560,495560,13107248,16750080,13084504,8243207,13442847,11444117,16674343,4298722,16235028,8221145,6670592,11444117,13084504,9960447,16763904);
			this.groupValueColours = new Array(16711884,16763904,495560,10717514,7385358,11444117,10606527,9598303,495560,495560,11444117,this.s_WarningCol,11444117,16777215,5652786,16777215,11444117,11444117,11444117,11444117,495560,13107248,495560,495560,13107248,16777215,11444117,7385358,16777215,495560,495560,13107248,16750080,13084504,8243207,13442847,11444117,16674343,4298722,16235028,8221145,6670592,11444117,13084504,9960447,11444117);
			this.isItem = false;
			this.isIdentified = true;
			var val1:Array = new Array("ItemName","ItemWeight","ItemGoldValue","ItemLevel","ItemDescription","ItemRarity","ItemUseAPCost","ItemAttackAPCost","StatBoost","ResistanceBoost","AbilityBoost","OtherStatBoost","VitalityBoost","ChanceToHitBoost","DamageBoost","APCostBoost","APMaximumBoost","APStartBoost","APRecoveryBoost","CritChanceBoost","ArmorBoost","ConsumableDuration","ConsumablePermanentDuration","ConsumableEffect","ConsumableDamage","ExtraProperties","Flags","ItemRequirement","WeaponDamage","WeaponDamagePenalty","WeaponCritMultiplier","WeaponCritChance","WeaponRange","Durability","CanBackstab","AccuracyBoost","DodgeBoost","EquipmentUnlockedSkill","WandSkill","WandCharges","ArmorValue","ArmorSlotType","Blocking","NeedsIdentifyLevel","IsQuestItem","PriceToIdentify","PriceToRepair","PickpocketInfo","Engraving","ContainerIsLocked","SkillName","SkillIcon","SkillSchool","SkillTier","SkillRequiredEquipment","SkillAPCost","SkillCooldown","SkillDescription","SkillProperties","SkillDamage","SkillRange","SkillExplodeRadius","SkillCanPierce","SkillCanFork","SkillStrikeCount","SkillProjectileCount","SkillCleansesStatus","SkillMultiStrikeAttacks","SkillWallDistance","SkillPathSurface","SkillPathDistance","SkillHealAmount","SkillDuration","ConsumableEffectUknown","Reflection","SkillAlreadyLearned","SkillOnCooldown","SkillAlreadyUsed","AbilityTitle","AbilityDescription","TalentTitle","TalentDescription","SkillMPCost","MagicArmorValue","WarningText","RuneSlot","RuneEffect","Equipped","ShowSkillIcon","SkillbookSkill","Tags","EmptyRuneSlot","StatName","StatsDescription","StatsDescriptionBoost","StatSTRWeight","StatMEMSlot","StatsPointValue","StatsTalentsBoost","StatsTalentsMalus","StatsBaseValue","StatsPercentageBoost","StatsPercentageMalus","StatsPercentageTotal","StatsGearBoostNormal","StatsATKAPCost","StatsCriticalInfos","StatsAPTitle","StatsAPDesc","StatsAPBase","StatsAPBonus","StatsAPMalus","StatsTotalDamage","TagDescription","StatusImmunity","StatusBonus","StatusMalus","StatusDescription","Title","SurfaceDescription","Duration","Fire","Water","Earth","Air","Poison","Physical","Sulfur","Heal","Splitter","ArmorSet");
			this.codeEnum = new Object();
			var val2:uint = 0;
			while(val2 < val1.length)
			{
				this.codeEnum[val1[val2]] = ++val2;
			}
			val1 = new Array("EqHeader","Warnings","Skills","Critical","Special","AP","SP","SavingThrow","Properties","Runes","RuneEffect","ActiveRuneEffect","InActiveRuneEffect","Tags","EmptyRunes","Description","STRMove","STRCarry","MEMSlots","StatsPointUp","StatsBonus","StatsMalus","StatsBase","StatsPercentageBoost","StatsPercentageMalus","StatsPercentageTotal","StatsGearBoostNormal","StatsATKAPCost","StatsAPTitle","StatsAPBase","StatsAPBonus","StatsAPMalus","SkillCurrentLevel","StatusImmunity","StatusBonus","StatusMalus","Duration","Fire","Water","Earth","Air","Poison","Physical","Sulfur","Heal","ArmorSet");
			this.grpsEnum = new Object();
			val2 = 0;
			while(val2 < val1.length)
			{
				this.grpsEnum[val1[val2]] = ++val2;
			}
		}
		
		public function setBGVisible(param1:Boolean) : *
		{
			if(this.header_mc)
			{
				this.header_mc.setBGVisible(param1);
			}
			if(this.middleBg_mc)
			{
				this.middleBg_mc.setBGVisible(param1);
			}
			if(this.footer_mc)
			{
				this.footer_mc.setBGVisible(param1);
			}
		}
		
		public function setGroupLabel(param1:Number, param2:String) : void
		{
			var val3:MovieClip = null;
			if(param1 >= 0 && param1 < this.groupLabels.length)
			{
				this.groupLabels[param1] = param2;
				val3 = this.list.getElementByNumber("groupID",param1);
				if(val3 != null)
				{
					val3.setTitleBar(this.groupLabels[param1],val3.iconId);
				}
			}
		}
		
		override public function get width() : Number
		{
			return this.tooltipW;
		}
		
		override public function get height() : Number
		{
			return Math.round(this.footer_mc.myH + this.footer_mc.y);
		}
		
		public function getHeight() : Number
		{
			return Math.round(this.footer_mc.myH + this.footer_mc.y);
		}
		
		public function hideFooter() : void
		{
			this.forceHideFooter = true;
			this.footer_mc.clearInfo();
		}
		
		public function addButtonHint(param1:Number, param2:String) : void
		{
			var val3:controllerBtnElement = new controllerBtnElement();
			if(val3)
			{
				val3.id = param1;
				val3.setBtnHint(param2,param1);
				this.buttonHints.addElement(val3);
				this.resetBackground();
			}
			else
			{
				Registry.ExtCall("UIAssert","addButtonHint in LSTooltipClass failed again because the flash exporter is CRAP");
			}
		}
		
		public function clearButtonHints() : void
		{
			this.buttonHints.clearElements();
			this.resetBackground();
		}
		
		public function setCompareHintVisible(param1:Boolean) : void
		{
			this.footer_mc.btnHints_mc.visible = param1;
			this.resetBackground();
		}
		
		private function resetBackground() : void
		{
			var val1:Number = NaN;
			var val2:Number = NaN;
			var val3:Number = NaN;
			var val4:Number = NaN;
			this.list.container_mc.scrollRect = null;
			if(this.footer_mc)
			{
				this.footer_mc.resetFooter();
			}
			if(this.header_mc)
			{
				this.header_mc.refreshBG();
				this.container_mc.y = this.header_mc.myH + this.header_mc.y;
			}
			if(!this.scaleH)
			{
				val1 = this.tooltipW - this.tooltipPaddingL - this.tooltipPaddingR + 14;
				if(this.footer_mc)
				{
					val2 = this.tooltipH - this.container_mc.y - this.tooltipPaddingB - this.footer_mc.myH;
				}
				else
				{
					val2 = this.tooltipH - this.container_mc.y - this.tooltipPaddingB;
				}
				this.list.setFrame(val1,val2);
				this.list.m_scrollbar_mc.scrollbarVisible();
				if(this.middleBg_mc)
				{
					this.middleBg_mc.y = this.container_mc.y;
					this.middleBg_mc.setBgHeight(val2);
				}
				if(this.footer_mc)
				{
					this.footer_mc.y = this.middleBg_mc.y + val2;
				}
			}
			else
			{
				if(this.middleBg_mc)
				{
					val3 = this.list.visibleHeight + this.tooltipPaddingB;
					if(this.maxH > 0 && val3 > this.maxH)
					{
						val3 = this.maxH + this.tooltipPaddingB;
					}
					this.middleBg_mc.y = this.container_mc.y;
					if(this.hasSubSections && this.list.length > 1)
					{
						this.middleBg_mc.setBgWSubsections(val3,this.maxH + this.tooltipPaddingB,this.list);
					}
					else
					{
						val4 = this.tooltipW - this.tooltipPaddingL - this.tooltipPaddingR + 14;
						this.list.setFrame(val4,val3);
						this.middleBg_mc.setBgHeight(val3);
					}
					this.list.m_scrollbar_mc.scrollbarVisible();
				}
				if(this.middleBg_mc && this.footer_mc)
				{
					this.footer_mc.y = this.middleBg_mc.y + this.middleBg_mc.height;
				}
				else if(this.footer_mc)
				{
					this.footer_mc.y = this.container_mc.y + this.list.y + this.list.height;
				}
			}
		}
		
		public function applyLeading(param1:MovieClip, param2:Number = 0) : void
		{
			var val3:Number = NaN;
			if(param1)
			{
				if(param2 == 0)
				{
					param2 = this.m_Leading * 0.5;
				}
				val3 = 0;
				if(param1.heightOverride)
				{
					val3 = param1.heightOverride / param2;
				}
				else
				{
					val3 = param1.height / param2;
				}
				val3 = Math.round(val3);
				if(val3 <= 0)
				{
					val3 = 1;
				}
				param1.heightOverride = val3 * param2;
			}
		}
		
		public function roundToLeading(param1:Number, param2:Number = 0) : Number
		{
			if(param2 == 0)
			{
				param2 = this.m_Leading * 0.5;
			}
			var val3:Number = param1 / param2;
			val3 = Math.round(val3);
			if(val3 <= 0)
			{
				val3 = 1;
			}
			return val3 * param2;
		}
		
		public function scrollDown() : void
		{
			this.list.m_scrollbar_mc.startAutoScroll(true);
		}
		
		public function scrollUp() : void
		{
			this.list.m_scrollbar_mc.startAutoScroll(false);
		}
		
		public function stopScrolling() : void
		{
			this.list.m_scrollbar_mc.stopAutoScroll();
		}
		
		private function getEquipHeader(param1:Boolean = true) : MovieClip
		{
			var val2:Class = null;
			if(this.equipHeader == null && param1)
			{
				val2 = Registry.GetClass("tt_EquipHeader");
				this.equipHeader = new val2();
				this.equipHeader.orderId = this.grpsEnum.EqHeader;
				this.equipHeader.init();
				this.equipHeader.base = this;
				this.list.addElement(this.equipHeader,false);
				this.hasSubSections = true;
			}
			return this.equipHeader;
		}
		
		public function repositionElements() : void
		{
			var val4:MovieClip = null;
			this.list.sortOnce("orderId",Array.NUMERIC,false);
			var val1:MovieClip = null;
			var val2:Number = this.m_Leading * 0.5;
			var val3:uint = 0;
			while(val3 < this.list.length)
			{
				val4 = this.list.getAt(val3);
				if(val4.list)
				{
					val4.list.positionElements();
				}
				if(val4 == this.equipHeader)
				{
					val4.updateHeight();
				}
				else
				{
					if(val4.needsSubSection)
					{
						if(!val4.heightOverride)
						{
							val4.heightOverride = val4.height;
						}
						val4.heightOverride = val4.heightOverride + val2;
						if(val1 && !val1.needsSubSection)
						{
							if(!val1.heightOverride)
							{
								val1.heightOverride = val1.height;
							}
							val1.heightOverride = val1.heightOverride + val2;
						}
					}
					this.applyLeading(val4);
				}
				val1 = val4;
				val3++;
			}
			this.list.positionElements();
			this.resetBackground();
		}
		
		public function clear() : void
		{
			var val1:uint = 0;
			this.hasSubSections = false;
			this.isEquipped = false;
			if(this.list)
			{
				val1 = 0;
				while(val1 < this.list.length)
				{
					if(this.list.content_array[val1].clearMC)
					{
						this.list.content_array[val1].clearMC();
					}
					val1++;
				}
				this.list.clearElements();
				if(this.header_mc)
				{
					this.header_mc.clearInfo();
				}
				if(this.footer_mc)
				{
					this.footer_mc.clearInfo();
				}
				if(this.middleBg_mc)
				{
					this.middleBg_mc.clearInfo();
				}
				if(this.list.container_mc.scrollRect != null)
				{
					this.list.m_scrollbar_mc.scrollbarVisible();
				}
			}
			this.isItem = false;
			this.equipHeader = null;
			this.isIdentified = true;
			if(this.unidentifiedMC != null)
			{
				this.unidentifiedMC = null;
			}
		}
		
		public function clearContent() : void
		{
			var val1:uint = 0;
			while(val1 < this.list.length)
			{
				if(this.list.content_array[val1].clearMC)
				{
					this.list.content_array[val1].clearMC();
				}
				val1++;
			}
			this.list.clearElements();
		}
		
		private function addGroup(param1:Number) : MovieClip
		{
			var val2:int = 0;
			var val3:Class = Registry.GetClass("tt_groupHolder");
			var val4:* = new val3();
			val4.init();
			val4.base = this;
			val4.groupID = param1;
			val4.labelColour = this.groupColours[param1];
			val4.valueColour = this.groupValueColours[param1];
			val4.warningColour = this.s_BonusColour;
			val4.descColour = this.groupColours[5];
			val4.penaltyColour = this.s_PenaltyColour;
			switch(param1)
			{
				case 1:
					val4.orderId = this.grpsEnum.Critical;
					val2 = 1;
					break;
				case 2:
					val4.orderId = this.grpsEnum.Special;
					val2 = 2;
					break;
				case 3:
					val4.orderId = this.grpsEnum.SavingThrow;
					val2 = 0;
					break;
				case 4:
					val4.orderId = this.grpsEnum.AP;
					val2 = 4;
					break;
				case 5:
					val4.orderId = this.grpsEnum.Properties;
					val2 = 5;
					break;
				case 6:
					val4.orderId = this.grpsEnum.SP;
					val2 = 6;
					break;
				case 7:
					val4.orderId = this.grpsEnum.Runes;
					val2 = 7;
					break;
				case 8:
					val4.orderId = this.grpsEnum.RuneEffect;
					val2 = 0;
					break;
				case 9:
					val4.orderId = this.grpsEnum.ActiveRuneEffect;
					val2 = 0;
					break;
				case 10:
					val4.orderId = this.grpsEnum.InActiveRuneEffect;
					val2 = 0;
					break;
				case 11:
					val4.orderId = this.grpsEnum.Warnings;
					val2 = 11;
					break;
				case 12:
					val4.orderId = this.grpsEnum.Skills;
					val2 = 0;
				case 13:
					val4.needsSubSection = true;
					val4.orderId = this.grpsEnum.Tags;
					val2 = 0;
					break;
				case 14:
					val4.orderId = this.grpsEnum.EmptyRunes;
					val2 = 13;
					break;
				case 15:
					val4.orderId = this.grpsEnum.Description;
					val2 = 0;
					break;
				case 16:
					val4.orderId = this.grpsEnum.STRMove;
					val2 = 14;
					break;
				case 17:
					val4.orderId = this.grpsEnum.STRCarry;
					val2 = 15;
					break;
				case 18:
					val4.orderId = this.grpsEnum.MEMSlots;
					val2 = 5;
					break;
				case 19:
					val4.orderId = this.grpsEnum.StatsPointUp;
					val2 = 16;
					break;
				case 20:
					val4.orderId = this.grpsEnum.StatsBonus;
					val2 = 2;
					break;
				case 21:
					val4.orderId = this.grpsEnum.StatsMalus;
					val2 = 11;
					break;
				case 22:
					val4.orderId = this.grpsEnum.StatsBase;
					val2 = 0;
					break;
				case 23:
					val4.orderId = this.grpsEnum.StatsPercentageBoost;
					val2 = 2;
					break;
				case 24:
					val4.orderId = this.grpsEnum.StatsPercentageMalus;
					val2 = 11;
					break;
				case 25:
					val4.orderId = this.grpsEnum.StatsPercentageTotal;
					val2 = 0;
					break;
				case 26:
					val4.orderId = this.grpsEnum.StatsGearBoostNormal;
					val2 = 0;
					break;
				case 27:
					val4.orderId = this.grpsEnum.StatsATKAPCost;
					val2 = 17;
					break;
				case 28:
					val4.orderId = this.grpsEnum.StatsAPTitle;
					val2 = 0;
					break;
				case 29:
					val4.orderId = this.grpsEnum.StatsAPMaxBase;
					val2 = 0;
					break;
				case 30:
					val4.orderId = this.grpsEnum.StatsAPMaxBonus;
					val2 = 2;
					break;
				case 31:
					val4.orderId = this.grpsEnum.StatsAPMaxMalus;
					val2 = 11;
					break;
				case 32:
					val4.orderId = this.grpsEnum.SkillCurrentLevel;
					val2 = 0;
					break;
				case 33:
					val4.orderId = this.grpsEnum.StatusImmunity;
					val2 = 0;
					break;
				case 34:
					val4.orderId = this.grpsEnum.StatusBonus;
					val2 = 0;
					break;
				case 35:
					val4.orderId = this.grpsEnum.StatusMalus;
					val2 = 0;
				case 45:
					val4.orderId = this.grpsEnum.ArmorSet;
					val4.needsSubSection = true;
					val2 = 18;
					break;
				case 46:
					val4.orderId = this.grpsEnum.ArmorSet + 1;
					val2 = 0;
			}
			val4.iconId = val2;
			val4.setupHeader();
			this.list.addElement(val4,false);
			return val4;
		}
		
		private function addGroupSurface(param1:Number) : MovieClip
		{
			var val2:int = 0;
			var val3:Class = Registry.GetClass("tt_surfaceGroup");
			var val4:* = new val3();
			val4.init();
			val4.base = this;
			val4.groupID = param1;
			val4.labelColour = this.groupColours[param1 == 1?15:34 + param1];
			val4.valueColour = this.groupValueColours[param1 == 1?15:34 + param1];
			val4.descColour = this.groupColours[5];
			switch(param1)
			{
				case 1:
					val4.orderId = this.grpsEnum.Description;
					val2 = 0;
					break;
				case 2:
					val4.orderId = this.grpsEnum.Duration;
					val2 = 1;
					break;
				case 3:
					val4.orderId = this.grpsEnum.Fire;
					val2 = 2;
					break;
				case 4:
					val4.orderId = this.grpsEnum.Water;
					val2 = 3;
					break;
				case 5:
					val4.orderId = this.grpsEnum.Earth;
					val2 = 4;
					break;
				case 6:
					val4.orderId = this.grpsEnum.Air;
					val2 = 5;
					break;
				case 7:
					val4.orderId = this.grpsEnum.Poison;
					val2 = 6;
					break;
				case 8:
					val4.orderId = this.grpsEnum.Physical;
					val2 = 7;
					break;
				case 9:
					val4.orderId = this.grpsEnum.Sulfur;
					val2 = 0;
					break;
				case 10:
					val4.orderId = this.grpsEnum.Heal;
					val2 = 0;
			}
			val4.iconId = val2;
			this.list.addElement(val4,false);
			return val4;
		}
		
		private function getGroup(param1:Number) : MovieClip
		{
			var val2:MovieClip = this.list.getElementByNumber("groupID",param1);
			if(val2 == null)
			{
				val2 = this.addGroup(param1);
			}
			return val2;
		}
		
		private function addDamage(param1:String, param2:Number, param3:Number, param4:Number) : void
		{
			this.getEquipHeader(true);
			if(this.equipHeader)
			{
				this.equipHeader.addDamage(param1,param2,param3,param4);
				this.equipHeader.needsSubSection = true;
			}
		}
		
		private function reOrderBottomBar() : void
		{
			if(this.footer_mc)
			{
				this.footer_mc.reOrderBottomBar();
			}
			if(!(!this.forceHideFooter && (this.footer_mc.labels_mc.visible || this.footer_mc.btnHints_mc.visible && this.buttonHints.length > 0)))
			{
				this.footer_mc.clearInfo();
			}
			this.resetBackground();
		}
		
		public function setupTooltip(param1:Array, param2:Number = 0) : void
		{
			var val4:MovieClip = null;
			var val5:String = null;
			var val6:String = null;
			var val7:String = null;
			var val8:String = null;
			var val9:Number = NaN;
			var val10:Number = NaN;
			var val11:Number = NaN;
			var val12:Boolean = false;
			var val14:Boolean = false;
			var val15:MovieClip = null;
			var val16:uint = 0;
			var val17:Number = NaN;
			var val18:String = null;
			var val19:String = null;
			var val20:Boolean = false;
			var val21:Boolean = false;
			var val22:Class = null;
			var val23:Class = null;
			var val24:Boolean = false;
			var val25:Boolean = false;
			var val26:String = null;
			var val27:Class = null;
			var val28:Class = null;
			var val29:Class = null;
			var val30:uint = 0;
			var val31:int = 0;
			var val32:int = 0;
			var val33:String = null;
			var val34:* = undefined;
			var val35:* = undefined;
			var val36:* = undefined;
			var val37:Class = null;
			var val38:* = undefined;
			var val39:int = 0;
			var val40:String = null;
			var val41:String = null;
			var val42:String = null;
			var val43:String = null;
			var val44:String = null;
			var val45:* = undefined;
			var val46:* = undefined;
			var val47:* = undefined;
			var val48:Boolean = false;
			var val49:* = undefined;
			var val50:int = 0;
			var val51:Class = null;
			var val52:MovieClip = null;
			var val53:uint = 0;
			var val54:uint = 0;
			var val55:uint = 0;
			var val56:uint = 0;
			this.clear();
			if(param2 != 0)
			{
				this.list.m_scrollbar_mc.m_SCROLLSPEED = param2;
				this.m_Leading = param2;
			}
			var val3:MovieClip = null;
			val4 = null;
			val5 = "";
			val6 = "";
			val7 = "";
			val8 = "";
			val9 = 0;
			val10 = 0;
			val11 = 0;
			val12 = false;
			var val13:Number = 0;
			val14 = false;
			val15 = null;
			val16 = 0;
			while(val16 < param1.length)
			{
				val17 = Number(param1[val16++]);
				val3 = null;
				val4 = null;
				val15 = null;
				val6 = "";
				val5 = "";
				val7 = "";
				val8 = "";
				val11 = 0;
				if(!isNaN(val17) && !val14)
				{
					switch(val17)
					{
						case this.codeEnum.ItemName:
							this.isItem = true;
							val5 = String(param1[val16++]);
							if(this.header_mc)
							{
								this.header_mc.setTitle(val5);
							}
							break;
						case this.codeEnum.ItemWeight:
							this.footer_mc.setWeight(String(param1[val16++]));
							val7 = param1[val16++];
							this.reOrderBottomBar();
							break;
						case this.codeEnum.ItemGoldValue:
							this.footer_mc.setGold(String(param1[val16++]));
							this.reOrderBottomBar();
							break;
						case this.codeEnum.ItemLevel:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl2(val5,val6);
							}
							break;
						case this.codeEnum.ItemDescription:
							val5 = param1[val16++];
							if(this.isIdentified)
							{
								val23 = Registry.GetClass("tt_description");
								val15 = new val23();
								if(val15)
								{
									val15.text_txt.textColor = this.groupColours[5];
									val15.text_txt.autoSize = TextFieldAutoSize.CENTER;
									val15.text_txt.multiline = true;
									val15.orderId = 256;
									val15.text_txt.htmlText = val5;
									this.list.addElement(val15,false);
									val15.needsSubSection = true;
									this.hasSubSections = true;
								}
							}
							else if(this.unidentifiedMC)
							{
								this.unidentifiedMC.desc_txt.autoSize = TextFieldAutoSize.CENTER;
								this.unidentifiedMC.desc_txt.htmlText = val5;
								this.unidentifiedMC.refreshPos();
							}
							break;
						case this.codeEnum.ItemRarity:
							this.footer_mc.setRarity(String(param1[val16++]));
							this.reOrderBottomBar();
							break;
						case this.codeEnum.ItemUseAPCost:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val24 = Boolean(param1[val16++]);
							if(this.header_mc)
							{
								this.header_mc.setAPUseCost(Number(val11));
								if(!val24)
								{
									this.header_mc.notEnoughAp();
								}
							}
							else
							{
								val4 = this.getGroup(4);
								if(val4)
								{
									val4.addEl(val11 + "",val5);
								}
							}
							break;
						case this.codeEnum.ItemAttackAPCost:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val8 = param1[val16++];
							val12 = Boolean(param1[val16++]);
							if(this.header_mc)
							{
								this.header_mc.setAPUseCost(Number(val11));
								if(!val12)
								{
									this.header_mc.notEnoughAp();
								}
							}
							else
							{
								val4 = this.getGroup(4);
								if(val4)
								{
									val4.addEl(val11 + "",val5,val8);
								}
							}
							break;
						case this.codeEnum.StatBoost:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val7 = param1[val16++];
							val8 = "";
							if(val11 > 0)
							{
								val8 = "+";
							}
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val8 + val11,val5);
							}
							break;
						case this.codeEnum.ResistanceBoost:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val7 = param1[val16++];
							val8 = "";
							if(val11 > 0)
							{
								val8 = "+";
							}
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val8 + val11 + "%",val5);
							}
							break;
						case this.codeEnum.AbilityBoost:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val7 = param1[val16++];
							val8 = "";
							if(val11 > 0)
							{
								val8 = "+";
							}
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val8 + val11,val5);
							}
							break;
						case this.codeEnum.OtherStatBoost:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val7 = param1[val16++];
							val25 = param1[val16++];
							val8 = "";
							if(val11 > 0)
							{
								val8 = "+";
							}
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val8 + val11,val5);
							}
							break;
						case this.codeEnum.VitalityBoost:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val6 = "";
								if(val11 > 0)
								{
									val6 = "+";
								}
								val4.addEl(val6 + val11,val5);
							}
							break;
						case this.codeEnum.ChanceToHitBoost:
						case this.codeEnum.DamageBoost:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.APCostBoost:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							break;
						case this.codeEnum.APMaximumBoost:
						case this.codeEnum.APStartBoost:
						case this.codeEnum.APRecoveryBoost:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(4);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.CritChanceBoost:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(1);
							if(val4)
							{
								val4.addEl(val6,val5);
							}
							break;
						case this.codeEnum.ArmorBoost:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.ConsumableDuration:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val6 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl2(val5,val6);
							}
							break;
						case this.codeEnum.ConsumablePermanentDuration:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.ConsumableEffect:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								if(val6 == "")
								{
									val4.addEl2(val5,"");
								}
								else
								{
									val4.addEl(val6,val5);
								}
							}
							break;
						case this.codeEnum.ConsumableDamage:
							val5 = param1[val16++];
							val9 = param1[val16++];
							val10 = param1[val16++];
							val13 = param1[val16++];
							val6 = param1[val16++];
							this.addDamage(val6,val9,val10,val13);
							break;
						case this.codeEnum.ExtraProperties:
							val5 = param1[val16++];
							val9 = param1[val16++];
							val7 = param1[val16++];
							val10 = param1[val16++];
							val6 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.Flags:
							val5 = param1[val16++];
							val7 = param1[val16++];
							val8 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl("",val5);
							}
							break;
						case this.codeEnum.ItemRequirement:
							val5 = param1[val16++];
							val7 = param1[val16++];
							val12 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								if(val12)
								{
									val4.addRequirement(val5,"",this.groupColours[5]);
								}
								else
								{
									val4.addRequirement(val5,"",this.s_WarningCol);
								}
							}
							break;
						case this.codeEnum.WeaponDamage:
							val9 = param1[val16++];
							val10 = param1[val16++];
							val26 = param1[val16++];
							val13 = param1[val16++];
							val7 = param1[val16++];
							this.addDamage(val26,val9,val10,val13);
							break;
						case this.codeEnum.WeaponDamagePenalty:
							val5 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.WeaponCritMultiplier:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val12 = param1[val16++];
							val6 = param1[val16++];
							val4 = this.getGroup(1);
							if(val4)
							{
								val4.addEl(val6,val5);
							}
							break;
						case this.codeEnum.WeaponCritChance:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val12 = param1[val16++];
							val4 = this.getGroup(1);
							if(val4)
							{
								val4.addEl(val6,val5);
							}
							break;
						case this.codeEnum.WeaponRange:
							val5 = param1[val16++];
							val7 = param1[val16++];
							val6 = param1[val16++];
							val12 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl(val6,val5);
							}
							break;
						case this.codeEnum.Durability:
							val5 = param1[val16++];
							val9 = param1[val16++];
							val10 = param1[val16++];
							val7 = param1[val16++];
							val12 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								if(val9 <= 0)
								{
									val4.addRequirement(val5,val9 + "/" + val10,this.s_WarningCol);
								}
								else
								{
									val4.addEl2(val5,val9 + "/" + val10);
								}
							}
							break;
						case this.codeEnum.CanBackstab:
							val5 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.AccuracyBoost:
						case this.codeEnum.DodgeBoost:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val7 = param1[val16++];
							val8 = "";
							if(val11 > 0)
							{
								val8 = "+";
							}
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val8 + val11 + "%",val5);
							}
							break;
						case this.codeEnum.EquipmentUnlockedSkill:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(12);
							if(val4)
							{
								val4.addWandSkill(val5,val6,"",val7);
								val4.needsSubSection = true;
							}
							break;
						case this.codeEnum.WandSkill:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val8 = param1[val16++];
							val4 = this.getGroup(12);
							if(val4)
							{
								val4.addWandSkill(val5,val6,val8,val7);
								val4.needsSubSection = true;
							}
							break;
						case this.codeEnum.WandCharges:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val10 = param1[val16++];
							val7 = param1[val16++];
							val12 = param1[val16++];
							val4 = this.getGroup(12);
							if(val4)
							{
								val4.needsSubSection = true;
								if(val6 == "-2")
								{
									val4.addRequirement(val5,"",this.s_WarningCol);
								}
								else
								{
									if(val6 == "-1")
									{
										val6 = "";
									}
									else
									{
										val6 = val6 + "/" + val10;
									}
									val4.addEl2(val5,val6);
								}
							}
							break;
						case this.codeEnum.ArmorValue:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val12 = param1[val16++];
							this.getEquipHeader(true);
							if(this.equipHeader)
							{
								this.equipHeader.addEl(val6,val5,2);
								this.equipHeader.needsSubSection = true;
							}
							break;
						case this.codeEnum.ArmorSlotType:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							this.getEquipHeader(true);
							if(this.equipHeader)
							{
								this.equipHeader.addEquipType(val5.toUpperCase());
							}
							break;
						case this.codeEnum.Blocking:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val12 = param1[val16++];
							this.getEquipHeader(true);
							if(this.equipHeader)
							{
								this.equipHeader.addEl(val6 + "%",val5,3);
								this.equipHeader.needsSubSection = true;
							}
							break;
						case this.codeEnum.NeedsIdentifyLevel:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							this.isIdentified = false;
							val27 = Registry.GetClass("tt_unidentified");
							this.unidentifiedMC = new val27();
							if(this.unidentifiedMC)
							{
								this.unidentifiedMC.text_txt.autoSize = TextFieldAutoSize.CENTER;
								this.unidentifiedMC.text_txt.multiline = true;
								this.unidentifiedMC.orderId = 2;
								this.unidentifiedMC.text_txt.htmlText = val5;
								this.unidentifiedMC.text_txt.textColor = this.s_ActionInfoCol;
								this.unidentifiedMC.refreshPos();
								this.list.addElement(this.unidentifiedMC,false);
							}
							break;
						case this.codeEnum.IsQuestItem:
							break;
						case this.codeEnum.PriceToIdentify:
						case this.codeEnum.PriceToRepair:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl2(val5,val6);
							}
							break;
						case this.codeEnum.PickpocketInfo:
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl(val6,"");
							}
							break;
						case this.codeEnum.Engraving:
							val6 = param1[val16++];
							val7 = param1[val16++];
							val28 = Registry.GetClass("tt_description");
							val15 = new val28();
							if(val15)
							{
								val15.text_txt.textColor = this.groupColours[5];
								val15.text_txt.autoSize = TextFieldAutoSize.CENTER;
								val15.text_txt.multiline = true;
								val15.orderId = 0;
								val15.text_txt.htmlText = String(val6);
								this.list.addElement(val15,false);
							}
							break;
						case this.codeEnum.ContainerIsLocked:
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl(val6,"");
							}
							break;
						case this.codeEnum.Tags:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val8 = param1[val16++];
							val4 = this.getGroup(13);
							if(val4)
							{
								val4.addTag(val5,val6,val8);
							}
							break;
						case this.codeEnum.SkillName:
							val5 = param1[val16++];
							if(this.isItem)
							{
								val4 = this.getGroup(2);
								if(val4)
								{
									val4.addEl(val5,"");
								}
							}
							else if(this.header_mc)
							{
								this.header_mc.setTitle(val5);
							}
							break;
						case this.codeEnum.SkillIcon:
							val5 = param1[val16++];
							break;
						case this.codeEnum.SkillSchool:
							if(this.footer_mc)
							{
								this.footer_mc.setSkillSchool(String(param1[val16++]),int(param1[val16++]),this.isItem);
							}
							else
							{
								val6 = param1[val16++];
								val7 = param1[val16++];
							}
							break;
						case this.codeEnum.SkillTier:
							val6 = param1[val16++];
							val7 = param1[val16++];
							break;
						case this.codeEnum.SkillRequiredEquipment:
							val5 = param1[val16++];
							val12 = param1[val16++];
							if(val12)
							{
								val4 = this.getGroup(5);
								if(val4)
								{
									val4.addEl2(val5);
								}
							}
							else
							{
								val4 = this.getGroup(11);
								if(val4)
								{
									val4.addWarning(val5);
								}
							}
							break;
						case this.codeEnum.SkillAPCost:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val8 = param1[val16++];
							val12 = Boolean(param1[val16++]);
							if(this.header_mc)
							{
								this.header_mc.setAPUseCost(Number(val11));
								if(!val12)
								{
									this.header_mc.notEnoughAp();
								}
							}
							else
							{
								val4 = this.getGroup(4);
								if(val4)
								{
									val4.addEl(val11 + "",val5,val8);
								}
							}
							break;
						case this.codeEnum.SkillCooldown:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val8 = param1[val16++];
							val7 = param1[val16++];
							val6 = param1[val16++];
							if(this.footer_mc && !this.isItem)
							{
								if(val11 > 0)
								{
									this.footer_mc.setCooldown(val11 + "");
								}
								else
								{
									this.footer_mc.setCooldown(val8);
								}
							}
							else
							{
								val4 = this.getGroup(5);
								if(val4)
								{
									val4.addEl2(val5,val6);
								}
							}
							break;
						case this.codeEnum.SkillDescription:
							val5 = param1[val16++];
							val29 = Registry.GetClass("tt_skillDescription");
							val15 = new val29();
							if(val15)
							{
								val15.text_txt.textColor = this.groupColours[5];
								val15.text_txt.autoSize = TextFieldAutoSize.CENTER;
								val15.text_txt.multiline = true;
								val15.orderId = this.grpsEnum.EqHeader;
								val15.text_txt.htmlText = val5;
								this.applyLeading(val15);
								val15.customElHeight = val15.heightOverride;
								this.list.addElement(val15,false);
							}
							break;
						case this.codeEnum.SkillProperties:
							val7 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val30 = 0;
								val31 = param1[val16++];
								if(val31 > 0)
								{
									val30 = 0;
									while(val30 < val31)
									{
										val6 = param1[val16++];
										val8 = param1[val16++];
										val4.addEl2(val6,"",val8);
										val30++;
									}
								}
								val32 = param1[val16++];
								if(val32 > 0)
								{
									val4 = this.getGroup(3);
									val30 = 0;
									while(val30 < val32)
									{
										val4.addResist(param1[val16++],param1[val16++]);
										val30++;
									}
								}
							}
							break;
						case this.codeEnum.SkillDamage:
							val5 = param1[val16++];
							val9 = param1[val16++];
							val10 = param1[val16++];
							val13 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							this.addDamage(val5,val9,val10,val13);
							break;
						case this.codeEnum.SkillRange:
							val6 = param1[val16++];
							val7 = param1[val16++];
							val5 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl(val6,val5);
							}
							break;
						case this.codeEnum.SkillExplodeRadius:
							val6 = param1[val16++];
							val7 = param1[val16++];
							val5 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl(val6,val5);
							}
							break;
						case this.codeEnum.SkillCanPierce:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.SkillCanFork:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val33 = param1[val16++];
							val10 = param1[val16++];
							val12 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.SkillStrikeCount:
						case this.codeEnum.SkillProjectileCount:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							break;
						case this.codeEnum.SkillCleansesStatus:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.SkillMultiStrikeAttacks:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val9 = param1[val16++];
							val10 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.SkillWallDistance:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.SkillPathSurface:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.SkillPathDistance:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl(val5,val6);
							}
							break;
						case this.codeEnum.SkillHealAmount:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val6 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl2(val5,val6);
							}
							break;
						case this.codeEnum.SkillDuration:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val8 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addEl2(val5,val8);
							}
							break;
						case this.codeEnum.ConsumableEffectUknown:
							val5 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl2(val5,"");
							}
							break;
						case this.codeEnum.Reflection:
							val5 = param1[val16++];
							val4 = this.getGroup(2);
							if(val4)
							{
								val4.addEl2(val5,"");
							}
							break;
						case this.codeEnum.SkillAlreadyLearned:
							val5 = param1[val16++];
							val4 = this.getGroup(11);
							if(val4)
							{
								val4.addWarning(val5);
							}
							break;
						case this.codeEnum.SkillOnCooldown:
							val5 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addRequirement(val5,"",this.s_WarningCol);
							}
							break;
						case this.codeEnum.SkillAlreadyUsed:
							val5 = param1[val16++];
							val4 = this.getGroup(5);
							if(val4)
							{
								val4.addRequirement(val5,"",this.s_WarningCol);
							}
							break;
						case this.codeEnum.AbilityTitle:
							val5 = param1[val16++];
							if(this.header_mc)
							{
								this.header_mc.setTitle(val5);
							}
							break;
						case this.codeEnum.AbilityDescription:
							this.AbilityId = param1[val16++];
							val5 = param1[val16++];
							val34 = param1[val16++];
							val35 = param1[val16++];
							val36 = param1[val16++];
							val37 = Registry.GetClass("tt_statsIcon");
							val38 = new val37();
							if(val38)
							{
								val38.initImage("iggy_tt_ability_" + this.AbilityId,20);
								val38.orderId = 1;
								val38.heightOverride = val38.blankSpace;
								this.applyLeading(val38);
								this.list.addElement(val38,false);
							}
							val4 = this.addGroup(15);
							if(val4)
							{
								val4.orderId = 2;
								val4.addDescription(val5);
								if(val34 != "")
								{
									val4.addDescription(val34);
								}
								val4.addWhiteSpace(val16,param1.length);
							}
							if(val35 != "")
							{
								val4 = this.getGroup(32);
								if(val4)
								{
									val4.orderId = 3;
									val4.addDescription(val35);
								}
							}
							if(val36 != "")
							{
								val4 = this.addGroup(15);
								if(val4)
								{
									val4.labelColour = this.groupColours[5];
									val4.orderId = 4;
									val4.addDescription(val36);
									val4.addWhiteSpace(val16,param1.length);
								}
							}
							break;
						case this.codeEnum.TalentTitle:
							val5 = param1[val16++];
							if(this.header_mc)
							{
								this.header_mc.setTitle(val5);
							}
							break;
						case this.codeEnum.TalentDescription:
							this.TalentId = param1[val16++];
							val5 = param1[val16++];
							val18 = param1[val16++];
							val19 = param1[val16++];
							val20 = param1[val16++];
							val21 = param1[val16++];
							val22 = Registry.GetClass("tt_statsIcon");
							val38 = new val22();
							if(val38)
							{
								val38.initImage("iggy_tt_talent_" + this.TalentId,20);
								val38.orderId = 1;
								val38.heightOverride = val38.blankSpace;
								this.applyLeading(val38);
								this.list.addElement(val38,false);
							}
							val4 = this.addGroup(15);
							if(val4)
							{
								val4.orderId = 2;
								val4.addDescription(val5);
								val4.addWhiteSpace(val16,param1.length);
							}
							if(val18 != "")
							{
								if(!val20)
								{
									val4 = this.addGroup(11);
								}
								else
								{
									val4 = this.addGroup(15);
								}
								if(val4)
								{
									if(val20)
									{
										val4.labelColour = this.groupColours[5];
									}
									val4.orderId = 3;
									val4.addDescription(val18);
								}
							}
							if(val19 != "")
							{
								if(!val21)
								{
									val4 = this.addGroup(11);
								}
								else
								{
									val4 = this.addGroup(15);
								}
								if(val4)
								{
									val4.orderId = 4;
									if(val21)
									{
										val4.labelColour = this.groupColours[5];
										val4.addDescription(val19);
									}
									else
									{
										val4.addWarning(val19);
									}
								}
							}
							break;
						case this.codeEnum.SkillMPCost:
							val5 = param1[val16++];
							val11 = param1[val16++];
							val12 = param1[val16++];
							if(this.header_mc)
							{
								this.header_mc.setSPUseCost(Number(val11));
								if(!val12)
								{
									this.header_mc.notEnoughSp();
								}
							}
							else
							{
								val4 = this.getGroup(6);
								if(val4)
								{
									val4.addEl2(val11 + "",val5);
								}
							}
							break;
						case this.codeEnum.MagicArmorValue:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val12 = param1[val16++];
							this.getEquipHeader(true);
							if(this.equipHeader)
							{
								this.equipHeader.addEl(val6,val5,4,4);
								this.equipHeader.needsSubSection = true;
							}
							break;
						case this.codeEnum.WarningText:
							val5 = param1[val16++];
							val4 = this.getGroup(11);
							if(val4)
							{
								val4.addWarning(val5);
							}
							break;
						case this.codeEnum.RuneSlot:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.addGroup(7);
							if(val4)
							{
								val4.addRuneSlot(val5,val6,"");
							}
							break;
						case this.codeEnum.RuneEffect:
							val39 = param1[val16++];
							val40 = param1[val16++];
							val41 = param1[val16++];
							val42 = param1[val16++];
							val43 = param1[val16++];
							val44 = param1[val16++];
							if(val39 == -1)
							{
								val4 = this.getGroup(8);
							}
							else
							{
								val4 = this.getGroup(9);
								if(val4)
								{
									val4.setTitle(val43);
								}
							}
							if(val4)
							{
								if(Boolean(val39 == 3 || val39 == -1))
								{
									val4.addRuneSlot(val40,"","",1);
								}
								if(Boolean(val39 == 1 || val39 == -1))
								{
									val4.addRuneSlot(val41,"","",2);
								}
								if(Boolean(val39 == 9 || val39 == -1))
								{
									val4.addRuneSlot(val42,"","",3);
								}
							}
							if(val39 != -1)
							{
								val4 = this.getGroup(10);
								if(val4)
								{
									val4.setTitle(val44);
									if(Boolean(val39 != 3))
									{
										val4.addRuneSlot(val40,"","",1);
									}
									if(Boolean(val39 != 1))
									{
										val4.addRuneSlot(val41,"","",2);
									}
									if(Boolean(val39 != 9))
									{
										val4.addRuneSlot(val42,"","",3);
									}
								}
							}
							break;
						case this.codeEnum.Equipped:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val8 = param1[val16++];
							if(this.footer_mc)
							{
								this.footer_mc.setEquip(val5);
							}
							if(this.header_mc)
							{
								this.header_mc.setEquip(val6);
							}
							this.isEquipped = true;
							if(val8 != "")
							{
								this.getEquipHeader(true);
								if(this.equipHeader)
								{
									this.equipHeader.setSlotInfo(val8);
								}
							}
							break;
						case this.codeEnum.ShowSkillIcon:
							val7 = param1[val16++];
							if(this.header_mc)
							{
								this.header_mc.bottom_mc.gotoAndStop(2);
							}
							break;
						case this.codeEnum.SkillbookSkill:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.getGroup(12);
							if(val4)
							{
								val4.orderId = 0;
								val4.addWandSkill(val5,val6,"",val7);
							}
							break;
						case this.codeEnum.EmptyRuneSlot:
							val5 = param1[val16++];
							val6 = param1[val16++];
							val7 = param1[val16++];
							val4 = this.addGroup(14);
							if(val4)
							{
								val4.addRuneSlot(val5,val6,"");
							}
							break;
						case this.codeEnum.StatName:
							val5 = String(param1[val16++]);
							if(this.header_mc)
							{
								this.header_mc.setTitle(val5);
								this.header_mc.centerTitle();
							}
							break;
						case this.codeEnum.StatsDescription:
							val5 = param1[val16++];
							val4 = this.addGroup(15);
							if(val4)
							{
								val4.orderId = 0;
								val4.addDescription(val5);
								val4.addWhiteSpace(val16,param1.length);
							}
							break;
						case this.codeEnum.StatsDescriptionBoost:
							val5 = param1[val16++];
							val45 = param1[val16++];
							val4 = this.getGroup(val45 > 0?Number(20):Number(21));
							if(val4)
							{
								val4.orderId = 1;
								val4.addEl(val5,"");
								val4.addWhiteSpace(val16,param1.length);
							}
							break;
						case this.codeEnum.StatSTRWeight:
							val5 = param1[val16++];
							val4 = this.getGroup(17);
							if(val4)
							{
								val4.orderId = 2;
								val4.addEl(val5,"");
								val4.addWhiteSpace(val16,param1.length);
							}
							break;
						case this.codeEnum.StatMEMSlot:
							val5 = param1[val16++];
							val4 = this.getGroup(18);
							if(val4)
							{
								val4.orderId = 2;
								val4.addEl(val5,"");
								val4.addWhiteSpace(val16,param1.length);
							}
							break;
						case this.codeEnum.StatsPointValue:
							val5 = param1[val16++];
							val4 = this.getGroup(19);
							if(val4)
							{
								val4.orderId = 3;
								val4.addEl(val5,"");
								val4.addWhiteSpace(val16,param1.length);
							}
							break;
						case this.codeEnum.StatsTalentsBoost:
							val5 = param1[val16++];
							val4 = this.addGroup(20);
							if(val4)
							{
								val4.orderId = 7;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsTalentsMalus:
							val5 = param1[val16++];
							val4 = this.addGroup(21);
							if(val4)
							{
								val4.orderId = 8;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsBaseValue:
							val5 = param1[val16++];
							val4 = this.getGroup(22);
							if(val4)
							{
								val4.orderId = 5;
								val4.addDescription(val5);
							}
							break;
						case this.codeEnum.StatsPercentageBoost:
							val5 = param1[val16++];
							val4 = this.addGroup(23);
							if(val4)
							{
								val4.orderId = 20;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsPercentageMalus:
							val5 = param1[val16++];
							val4 = this.addGroup(24);
							if(val4)
							{
								val4.orderId = 21;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsPercentageTotal:
							val5 = param1[val16++];
							val46 = param1[val16++];
							val4 = this.getGroup(25);
							if(val4)
							{
								if(val46 < 0)
								{
									val4.labelColour = this.groupColours[this.grpsEnum.StatsTalentsMalus];
								}
								val4.orderId = 19;
								val4.addWhiteSpace(val16,param1.length);
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsGearBoostNormal:
							val5 = param1[val16++];
							val4 = this.addGroup(26);
							if(val4)
							{
								val4.orderId = 2;
								val4.addEl(val5,"");
								val4.addWhiteSpace(val16,param1.length);
							}
							break;
						case this.codeEnum.StatsATKAPCost:
							val5 = param1[val16++];
							val47 = this.addGroup(15);
							if(val47)
							{
								val47.orderId = 99;
								val47.addWhiteSpace(val16,param1.length);
							}
							val4 = this.getGroup(27);
							if(val4)
							{
								val4.orderId = 100;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsCriticalInfos:
							val5 = param1[val16++];
							val4 = this.getGroup(1);
							if(val4)
							{
								val4.orderId = 15;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsAPTitle:
							val5 = param1[val16++];
							val48 = this.list.getElementByNumber("groupID",28) == null;
							val4 = this.addGroup(28);
							if(val4)
							{
								if(!val48)
								{
									val4.addWhiteSpace(val16,param1.length);
								}
								val4.orderId = val16;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsAPDesc:
							val5 = param1[val16++];
							val4 = this.addGroup(15);
							if(val4)
							{
								val4.labelColour = this.groupColours[5];
								val4.orderId = val16;
								val4.addDescription(val5);
							}
							break;
						case this.codeEnum.StatsAPBase:
							val5 = param1[val16++];
							val4 = this.addGroup(22);
							if(val4)
							{
								val4.orderId = val16;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsAPBonus:
							val5 = param1[val16++];
							val4 = this.addGroup(20);
							if(val4)
							{
								val4.orderId = val16;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsAPMalus:
							val5 = param1[val16++];
							val4 = this.addGroup(21);
							if(val4)
							{
								val4.orderId = val16;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatsTotalDamage:
							val5 = param1[val16++];
							val4 = this.addGroup(15);
							if(val4)
							{
								val4.orderId = 1;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.TagDescription:
							val49 = 0;
							val5 = param1[val16++];
							val50 = param1[val16++];
							if(val50 > 0)
							{
								val51 = Registry.GetClass("tt_statsIcon");
								val52 = new val51();
								if(val52)
								{
									val52.initImage("iggy_tt_tag_" + val50,20);
									val52.orderId = 1;
									val52.heightOverride = val52.blankSpace;
									this.applyLeading(val52);
									this.list.addElement(val52,false);
									val49 = val52.postSpace;
								}
							}
							val4 = this.getGroup(15);
							if(val4)
							{
								val4.orderId = 2;
								val4.addDescription(val5);
								if(val49 > 0)
								{
									val4.addWhiteSpace(val16,param1.length,val49);
								}
							}
							break;
						case this.codeEnum.StatusImmunity:
							val5 = param1[val16++];
							val4 = this.addGroup(33);
							if(val4)
							{
								val4.orderId = val16;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatusBonus:
							val5 = param1[val16++];
							val4 = this.addGroup(34);
							if(val4)
							{
								val4.orderId = val16;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatusMalus:
							val5 = param1[val16++];
							val4 = this.addGroup(35);
							if(val4)
							{
								val4.orderId = val16;
								val4.addEl(val5,"");
							}
							break;
						case this.codeEnum.StatusDescription:
							val5 = param1[val16++];
							val4 = this.addGroup(15);
							if(val4)
							{
								val4.orderId = val16;
								val4.addWhiteSpace(val16,param1.length);
								val4.addDescription(val5);
							}
							break;
						case this.codeEnum.Title:
							val5 = param1[val16++];
							val5 = val5.toUpperCase();
							val4 = this.addGroupSurface(1);
							if(val4)
							{
								val4.orderId = val16;
								val4.addDescription(val5);
							}
							break;
						case this.codeEnum.SurfaceDescription:
							val5 = param1[val16++];
							val4 = this.addGroupSurface(1);
							if(val4)
							{
								val4.orderId = val16;
								val4.addDescription(val5);
							}
							break;
						case this.codeEnum.Duration:
							val5 = param1[val16++];
							val4 = this.addGroupSurface(2);
							if(val4)
							{
								val4.orderId = val16;
								val4.addIconDesc(val5);
							}
							break;
						case this.codeEnum.Fire:
							val5 = param1[val16++];
							val4 = this.addGroupSurface(3);
							if(val4)
							{
								val4.orderId = val16;
								val4.addIconDesc(val5);
							}
							break;
						case this.codeEnum.Water:
							val5 = param1[val16++];
							val4 = this.addGroupSurface(4);
							if(val4)
							{
								val4.orderId = val16;
								val4.addIconDesc(val5);
							}
							break;
						case this.codeEnum.Earth:
							val5 = param1[val16++];
							val4 = this.addGroupSurface(5);
							if(val4)
							{
								val4.orderId = val16;
								val4.addIconDesc(val5);
							}
							break;
						case this.codeEnum.Air:
							val5 = param1[val16++];
							val4 = this.addGroupSurface(6);
							if(val4)
							{
								val4.orderId = val16;
								val4.addIconDesc(val5);
							}
							break;
						case this.codeEnum.Poison:
							val5 = param1[val16++];
							val4 = this.addGroupSurface(7);
							if(val4)
							{
								val4.orderId = val16;
								val4.addIconDesc(val5);
							}
							break;
						case this.codeEnum.Physical:
							val5 = param1[val16++];
							val4 = this.addGroupSurface(8);
							if(val4)
							{
								val4.orderId = val16;
								val4.addIconDesc(val5);
							}
							break;
						case this.codeEnum.Sulfur:
							val5 = param1[val16++];
							val4 = this.addGroupSurface(9);
							if(val4)
							{
								val4.orderId = val16;
								val4.addIconDesc(val5);
							}
							break;
						case this.codeEnum.Heal:
							val5 = param1[val16++];
							val4 = this.addGroupSurface(10);
							if(val4)
							{
								val4.orderId = val16;
								val4.addIconDesc(val5);
							}
							break;
						case this.codeEnum.Splitter:
							val4 = this.addGroupSurface(1);
							if(val4)
							{
								val4.orderId = val16;
								val4.addWhiteSpace(val16,param1.length);
							}
							break;
						case this.codeEnum.ArmorSet:
							val4 = this.getGroup(45);
							if(val4)
							{
								val5 = param1[val16++];
								val53 = uint(param1[val16++]);
								val54 = uint(param1[val16++]);
								val4.addEl(val5 + " (" + val53 + "/" + val54 + ")");
							}
							val4 = this.addGroup(46);
							if(val4)
							{
								val5 = param1[val16++];
								val4.addDescription(val5);
								val4.addWhiteSpace();
								val11 = param1[val16++];
								val55 = 0;
								while(val55 < val11)
								{
									if(val55 > 0)
									{
										val4.addWhiteSpace(-1,1,25);
									}
									val5 = param1[val16++];
									val7 = param1[val16++];
									val4.addWandSkill("",val5,"",val7);
									val55++;
								}
								val11 = param1[val16++];
								val56 = 0;
								while(val56 < val11)
								{
									if(val56 > 0)
									{
										val4.addWhiteSpace(-1,1,25);
									}
									val5 = param1[val16++];
									val7 = param1[val16++];
									val4.addWandSkill("",val5,"",val7);
									val56++;
								}
							}
							break;
						default:
							Registry.ExtCall("UIAssert","LSTooltipClass::setupTooltip error UNKNOWN TYPE PLEASE IMPLEMENT:" + val17);
							val14 = true;
					}
				}
				else
				{
					Registry.ExtCall("UIAssert","LSTooltipClass::setupTooltip error param:" + param1[val16++]);
					val14 = true;
				}
			}
			this.repositionElements();
		}
	}
}
